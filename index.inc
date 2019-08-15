<div id="subscriptionsTemplate" style="opacity:0" :style="{opacity: opacity}">
	<ol class="breadcrumb">
		<li><a href="/">Home</a></li>
		<li><a href="/dashboard">Dashboard</a></li>
		<li class="active">Tuition Plans</li>
	</ol>
	<div class="row">
		<div class="col-sm-4 col-md-3" id="dashboardNavigation"></div>
		<div class="col-sm-8 col-md-9">
			<h3 class="noRobotoSlab noTop fullBottom">Tuition Plans</h3>
			<p class="lead noMargin text-muted" v-if="noSubs"><em>You have no recurring subscriptions.</em></p>
			<div v-for="(subscription, type) in subscriptions" v-if="subscription.length" class="panel panel-default">
				<div class="panel-heading" v-if="type != 'aa'">
					<h3 class="panel-title">
						<span v-if="type == 'channels'">Channels</span>
						<span v-else-if="type == 'private_lessons'">Ongoing Private Lessons</span>
						<span v-else>{{type}}</span>
					</h3>
				</div>
				<div class="list-group">
					<div v-for="item in subscription" class="list-group-item fullItemPadding">

						<div v-if="item.label == 'All Access'" class="fullBottom" ><img src="/inc/img/all-access/aa-thin.svg" style="height:60px" /></div>
						<h4 v-else class="noTop midBottom noRobotoSlab">{{item.label}}</h4>

						<i v-if="item.loading" class="far fa-spinner fa-pulse text-muted"></i>

						<div v-else>

							<div class="fullBottom" v-if="type == 'aa' && item.frequency != 'lifetime'">
								You are currently enrolled in an All Access <span v-html="tf.capitalize(item.frequency)"></span> Tuition Plan.
							</div>
							<div class="fullBottom" v-else-if="type == 'channels'">
								You are currently enrolled in the {{item.label}} monthly tuition plan.
							</div>

							<div class="fullBottom" v-if="item.renew">

								<div class="fullBottom" v-if="type == 'aa' && item.frequency != 'lifetime'">

									<div class="fullBottom" v-if="!item.payment_profile || (item.payment_profile &&(item.payment_profile.type != 'apple'))">
										Your tuition plan will auto-renew on <strong>{{item.expirationDate}}</strong> <span v-if="item.rate">for <strong v-html="'$' + item.rate.toFixed(2)"></strong>.</span>
									</div>

									<span v-if="item.payment_profile && (item.payment_profile.type == 'credit card')">
										to <strong v-if="item.payment_profile.details.alias">{{item.payment_profile.details.alias}} ({{item.payment_profile.details.cardtype}})</strong>
										<strong v-else>{{item.payment_profile.details.cardtype}}</strong>
									</span>
									<span v-else-if="item.payment_profile && (item.payment_profile.type == 'paypal')">to <strong>PayPal</strong></span>
									<div class="fullBottom" v-if="item.frequency == 'annual' && (item.payment_profile && (item.payment_profile.type != 'apple'))">You can add on additional years, upgrade to Lifetime, or cancel at any time.</div>
									<div class="fullBottom" v-else-if="item.payment_profile && (item.payment_profile.type != 'apple')">You can upgrade to Annual, upgrade to Lifetime, or cancel at any time.</div>
									<div>
										<em v-if="item.payment_profile && (item.payment_profile.type == 'apple')" class="text-muted">To manage this tuition plan, go to the settings in your iOS device.
										<a href="https://support.apple.com/en-ph/HT202039" target="_blank">Read More</a></em>
									</div>
								</div>

								<div class="fullBottom" v-else-if="type == 'channels'">
									Your tuition plan will renew on <strong>{{item.expirationDate}}</strong> <span v-if="item.rate">for <strong v-html="'$' + item.rate.toFixed(2)"></strong></span>
									<span v-if="item.payment_profile && (item.payment_profile.type == 'credit card')">
										to <strong v-if="item.payment_profile.details.alias">{{item.payment_profile.details.alias}} ({{item.payment_profile.details.cardtype}})</strong>
										<strong v-else>{{item.payment_profile.details.cardtype}}</strong>
									</span>
									<span v-else-if="item.payment_profile && (item.payment_profile.type == 'paypal')">to <strong>PayPal</strong></span>.
									You can upgrade or cancel at any time.
								</div>

								<div class="fullBottom" v-else-if="type == 'private_lessons'">
										Next charge is on <strong>{{item.expirationDate}}</strong>
										<strong v-if="item.rate && (!isNaN(item.rate))" v-html="'for $' + item.rate.toFixed(2)"></strong>
										<span v-if="item.payment_profile && (item.payment_profile.type == 'credit card') && item.renew">
											to <strong v-if="item.payment_profile.details.alias">{{item.payment_profile.details.alias}} ({{item.payment_profile.details.cardtype}})</strong>
											<strong v-else>{{item.payment_profile.details.cardtype}}</strong>
										</span>
										<span v-else-if="item.payment_profile && (item.payment_profile.type == 'paypal')">to <strong>PayPal</strong></span>.
								</div>

								<div class="fullBottom" v-if="!item.payment_profile || (item.payment_profile && (item.payment_profile.type != 'apple'))" class="tinyTop">
									<a href="#" @click.prevent="renewSubscription(item, type, true)">Change Payment Method</a>
									<span v-if="item.frequency == 'annual' || item.frequency == 'monthly' && item-type == 'aa'">
										&nbsp;|&nbsp;
										<a href="/all-access/upgrade" v-if="item.frequency == 'annual'">Upgrade to Lifetime Plan</a>
										<a href="/all-access/upgrade" v-else-if="item.frequency == 'monthly'">Upgrade to Annual or Lifetime Plan</a>
									</span>
									<span v-else-if="type == 'channels' && item.access < 4">
										&nbsp;|&nbsp;
										<a :href="'/h' + item.channel_id">Upgrade Your Tuition Plan</a>
									</span>
									&nbsp;|&nbsp;
									<a href="#" @click.prevent="cancelSubscription(item, type)">Cancel</a>
								</div>

								<div class="alert alert-danger fullTop noBottom" v-if="item.payment_profile && (item.payment_profile == 'not set')">
									<i class="fas fa-exclamation-triangle"></i>&nbsp;&nbsp;The payment method associated with this tuition plan is invalid. <a href="#" @click.prevent="renewSubscription(item, type, true)">Click here</a> to update or add a payment profile.
								</div>

							</div>


							<div class="fullBottom" v-else-if="!item.renew && item.frequency != 'lifetime'">
								<div class="tinyBottom" v-if="!item.payment_profile || (item.payment_profile && (item.payment_profile.type != 'apple'))">
									Your tuition plan is set to expire on <strong>{{item.expirationDate}}</strong>. You will continue to have access until then and can
									<span v-if="type == 'aa' && item.frequency == 'annual' && item.payment_profile == 'not set'">extend</span>
									<span v-else>renew</span>
									at any time.
								</div>
								<div v-if="item.payment_profile && (item.payment_profile.type == 'apple')">
									<em class="text-muted">To manage this tuition plan, go to the settings in your Apple device.
									<a href="https://support.apple.com/en-ph/HT202039" target="_blank">Read More</a></em>
								</div>
								<div v-else>
									<a href="/all-access/renew" v-if="type == 'aa' && item.frequency == 'annual' && item.payment_profile == 'not set'">Extend Tuition Plan</a>
									<a href="#" v-else @click.prevent="renewSubscription(item, type)">Renew Tuition Plan</a>
								</div>

							</div>

							<div v-if="item.frequency == 'lifetime'">
								You are currently enrolled in the All Access Lifetime Plan. Your access never expires.
							</div>

							<!-- <br/>
							<pre>{{item}}</pre> -->
							<!-- <div v-if="type != 'aa' && item.renew && (item.frequency == 'monthly' || item.frequency == 'annual') && item.expires && (!item.payment_profile || (item.payment_profile && item.payment_profile != 'not set'))">
								<div class="tinyBottom">
									<span v-if="!item.payment_profile || (item.payment_profile && (item.payment_profile.type != 'apple'))">
										<div v-if="type == 'aa'">
										</div>
										<div v-else>
											Next charge is on <strong>{{item.expirationDate}}</strong>
											<strong v-if="item.rate && (!isNaN(item.rate))" v-html="'for $' + item.rate.toFixed(2)"></strong>
											<span v-if="item.payment_profile && (item.payment_profile.type == 'credit card') && item.renew">
												to <strong v-if="item.payment_profile.details.alias">{{item.payment_profile.details.alias}} ({{item.payment_profile.details.cardtype}})</strong>
												<strong v-else>{{item.payment_profile.details.cardtype}}</strong>
											</span>
											<span v-else-if="item.payment_profile && (item.payment_profile.type == 'paypal')">to <strong>PayPal</strong></span>.
										</div>
									</span>
								</div>
								<em v-if="item.payment_profile && (item.payment_profile.type == 'apple')" class="text-muted">To manage this subscription, go to the settings/subscriptions in your Apple device.
									<a href="https://support.apple.com/en-ph/HT202039" target="_blank">Read More</a></em>
								<span v-else>
									<a href="#" @click.prevent="cancelSubscription(item, type)">Cancel Subscription</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="#" @click.prevent="renewSubscription(item, type, true)">Change Payment Method</a>
								</span>
							</div> -->
							<!-- <div v-if="item.frequency == 'lifetime'">Lifetime Subscription</div> -->
							<!-- <div v-else-if="(!item.renew && item.expires && item.payment_profile || (item.renew && item.payment_profile == 'not set')) && item.frequency != 'lifetime'">
								<div class="tinyBottom">
									<span v-if="type = 'aa'">Your subscription is set to expire on <strong>{{item.expirationDate}}</strong>. You will continue to have access until then and can renew at any time.</span>
									<span v-html="tf.capitalize(item.frequency)"></span> subscription. Set to expire on <strong>{{item.expirationDate}}.</strong>
								</div>
								<a href="#" @click.prevent="renewSubscription(item, type)">Renew Subscription</a>
							</div> -->

						</div>

					</div>
				</div>
			</div>
		</div>
	</div>

	<modal v-model="cancelSubscriptionModal" title="Cancel Tuition Plan">
		Are you sure you want to cancel your {{currentSubscription.frequency}} {{currentSubscription.label}} tuition plan? Your tuition plan will be good until <strong>{{currentSubscription.expirationDate}}</strong>,
		you may renew at any time until then.
		<div slot="footer">
			<btn @click="cancelSubscriptionModal = false">No</btn>
			<btn type="danger" @click="cancelAASubscription" v-if="currentType == 'aa'">Yes, Cancel All Access Tuition Plan</btn>
			<btn type="danger" @click="cancelChannelSubscription" v-else-if="currentType == 'channels'">Yes, Cancel Channel Tuition Plan</btn>
			<btn type="danger" @click="cancelPrivateLessonSubscription" v-else-if="currentType == 'private_lessons'">Yes, Cancel Private Lessons</btn>
		</div>
	</modal>

	<modal v-model="renewSubscriptionModal" :title="isChange ? 'Change Payment Method' : 'Renew Tuition Plan'" >

		<div v-if="newPaymentMethodError" class="alert alert-danger moreMidBottom">
			<!-- <strong v-html="newPaymentMethodError"></strong> -->
			<strong>An error was detected. Please try again.</strong>
		</div>

		<div class="midBottom" v-if="isChange">
			Select a new payment method for your {{currentSubscription.frequency}} {{currentSubscription.label}} tuition plan.
		</div>
		<div class="midBottom" v-else>
			Are you sure you want to renew your {{currentSubscription.frequency}} {{currentSubscription.label}} tuition plan? You will be charged
			<strong v-if="currentSubscription.rate && (!isNaN(currentSubscription.rate))" v-html="'$' + currentSubscription.rate.toFixed(2)"></strong>
			<span v-else>again</span>
			on <strong>{{currentSubscription.expirationDate}}</strong>
			<span v-if="currentSubscription.payment_profile && (currentSubscription.payment_profile.details && (currentSubscription.payment_profile.details.alias))"></span>.
		</div>

		<div v-if="billingOptions && !newPaymentMethodForm.visible">
			<!-- <pre>{{currentSubscription}}</pre> -->
			<div v-for="(group, label) in billingOptions">
				<div v-for="item in group">
					<div class="subscriptionBillingSelectItem">
						<i class="fab fa-fw fa-cc-paypal fa-3x" v-if="item.billing_agreement"></i>
						<i class="fab fa-fw fa-cc-mastercard fa-3x" v-else-if="item.details && (item.details.payment && (item.details.payment.creditCard && (item.details.payment.creditCard.cardType && (item.details.payment.creditCard.cardType.toLowerCase().replace(/ /g, '') == 'mastercard'))))"></i>
						<i class="fab fa-fw fa-cc-visa fa-3x" v-else-if="item.details && (item.details.payment && (item.details.payment.creditCard && (item.details.payment.creditCard.cardType && (item.details.payment.creditCard.cardType.toLowerCase() == 'visa'))))"></i>
						<i class="fab fa-fw fa-cc-amex fa-3x" v-else-if="item.details && (item.details.payment && (item.details.payment.creditCard && (item.details.payment.creditCard.cardType && (item.details.payment.creditCard.cardType.toLowerCase().replace(/ /g, '') == 'americanexpress'))))"></i>
						<div class="infoContainer clearfix">
							<h5 class="noTop tinyBottom">
								<span v-if="item.alias">{{item.alias}}</span>
								<span v-if="item.details && (item.details.payment && (item.details.payment.creditCard && (item.details.payment.creditCard.cardType)))">{{item.details.payment.creditCard.cardType}}</span>
								<span v-if="item.details && (item.details.payment && (item.details.payment.creditCard && (item.details.payment.creditCard.cardNumber)))">({{item.details.payment.creditCard.cardNumber}})</span>
							</h5>
							<a href="#" @click.prevent="useProfile(item)" v-if="!currentSubscription.payment_profile || (currentSubscription.payment_profile.id != item.id && currentSubscription.payment_profile.id != item.billing_agreement) || (currentSubscription.payment_profile && currentSubscription.payment_profile == 'not set')">Use this profile</a>
							<em v-else-if="currentSubscription.payment_profile && (currentSubscription.payment_profile.id == item.id || currentSubscription.payment_profile.id == item.billing_agreement)" class="text-muted">Will be used for renewal</em>
						</div>
					</div>
				</div>
			</div>
		</div>
		<div v-else-if="!billingOptions" class="midBottom"><i class="far fa-spinner fa-pulse text-muted"></i></div>
		<a href="#" v-if="!newPaymentMethodForm.visible" @click.prevent="newPaymentMethodForm.visible = true">Use New Payment Method</a>
		<div v-else-if="newPaymentMethodForm.visible">
			<hr class="moreMidTop" />
			<h5 class="noRobotoSlab noTop moreMidBottom">Use New Payment Method</h5>
			<div class="form-horizontal clearfix">

				<div class="form-group" v-for="field in newPaymentMethodForm.fields" v-if="field.label != 'Region' || (field.label == 'Region' && newPaymentMethodForm.regions)" :class="{'has-error': !field.valid}">
					<label class="control-label col-sm-4">
						<span v-if="field.label == 'Region' && newPaymentMethodForm.country.name == 'United States'">State</span>
						<span v-else-if="field.label == 'Region' && newPaymentMethodForm.country.name == 'Canada'">Province</span>
						<span v-else>{{field.label}}</span>
					</label>
					<div class="col-sm-8">
						<input v-if="field.type == 'text'" class="form-control" type="text" v-model="field.value" :autocomplete="field.auto ? field.auto : ''" />
						<input v-else-if="field.type == 'number'" class="form-control" type="number" v-model="field.value" :autocomplete="field.auto ? field.auto : ''" />
						<select v-else-if="field.type == 'select' && field.label == 'Country'" class="form-control" @change="checkCountry" v-model="field.value">
							<option value="">- Select a Country -</option>
							<option :value="value" v-for="(country, value) in tf.countries">{{country.name}}</option>
						</select>
						<select v-else-if="field.type == 'select' && field.label == 'Region'" class="form-control" v-model="field.value">
							<option value="">- Select -</option>
							<option v-for="(region, value) in newPaymentMethodForm.regions" :value="value">{{region}}</option>
						</select>
					</div>
				</div>

				<div class="form-group">
					<div class="col-sm-8 col-sm-push-4">
						<div class="checkbox" style="padding-top:0">
							<label>
								<input type="checkbox" v-model="newPaymentMethodForm.default" /> Use as Default
							</label>
						</div>
					</div>
				</div>

				<div class="pull-right">
					<btn @click="newPaymentMethodForm.visible = false">Cancel</btn>
					<btn type="primary" @click="addNewPaymentProfile">Add</btn>
				</div>

			</div>


		</div>
					<div slot="footer">
						<btn @click="renewSubscriptionModal = false">Cancel</btn>
						<btn type="primary" @click="renewAASubscription" v-if="currentType == 'aa'" :disabled="newPaymentMethodForm.visible">
							<span v-if="isChange">Yes, Change Payment Method</span>
							<span v-else>Yes, Renew All Access Tuition Plan</span>
						</btn>
						<btn type="primary" @click="renewChannelSubscription" v-else-if="currentType == 'channels'" :disabled="newPaymentMethodForm.visible">
							<span v-if="isChange">Yes, Change Payment Method</span>
							<span v-else>Yes, Renew Channel Tuition Plan</span>
						</btn>
						<btn type="primary" @click="renewPrivateLessonSubscription" v-else-if="currentType == 'private_lessons'" :disabled="newPaymentMethodForm.visible">
							<span v-if="isChange">Yes, Change Payment Method</span>
							<span v-else>Yes, Renew Private Lesson Tuition Plan</span>
						</btn>
					</div>

<!-- 		<div slot="footer">
			<btn @click="renewSubscriptionModal = false">Cancel</btn>
			<btn type="primary" @click="renewAASubscription" v-if="currentType == 'aa'" :disabled="newPaymentMethodForm.visible">
				<span v-if="isChange">Yes, Change Payment Method</span>
				<span v-else>Yes, Renew All Access Tuition Plan</span>
			</btn>
			<btn type="primary" @click="renewChannelSubscription" v-else-if="currentType == 'channels'" :disabled="newPaymentMethodForm.visible">
				<span v-if="isChange">Yes, Change Payment Method</span>
				<span v-else>Yes, Renew Channel Tuition Plan</span>
			</btn>
			<btn type="primary" @click="renewPrivateLessonSubscription" v-else-if="currentType == 'private_lessons'" :disabled="newPaymentMethodForm.visible">
				<span v-if="isChange">Yes, Change Payment Method</span>
				<span v-else>Yes, Renew Private Lesson Tuition Plan</span>
			</btn>
		</div> -->

	</modal>

</div>
<script src="/inc/views/dashboard/global.js?v=<?=filemtime('/sumer/html/inc/views/dashboard/global.js')?>"></script>
<script>
document.addEventListener('DOMContentLoaded', function(){
tf.checkAuth(function(){
	tf.dashboardNavigation('subscriptions');
	collectionsTemplate = new Vue({
		el: '#subscriptionsTemplate',
		data: {
			opacity: 1,
			subscriptions: false,
			noSubs: false,
			currentSubscription: false,
			currentType: false,
			cancelSubscriptionModal: false,
			renewSubscriptionModal: false,
			billingOptions: false,
			newPaymentMethodForm: {
				visible: false,
				fields: [
					{label: 'Nickname (Optional)', key: 'alias', type: 'text', required: false, value: '', valid: true},
					{label: 'Card Number', auto: 'cc-number', key: 'cc', type: 'number', required: true, value: '', valid: true},
					{label: 'Expiration Date', auto: 'cc-exp', key: 'exp', type: 'text', required: true, value: '', valid: true},
					{label: 'CVV Number', auto: 'cc-csc', key: 'cvv', type: 'number', required: true, value: '', valid: true},
					{label: 'First Name', key: 'firstname', type: 'text', required: true, value: '', valid: true},
					{label: 'Last Name', key: 'lastname', type: 'text', required: true, value: '', valid: true},
					{label: 'Address', key: 'address', type: 'text', required: true, value: '', valid: true},
					{label: 'Country', key: 'country', type: 'select', required: true, value: '', valid: true},
					{label: 'Region', key: 'state', type: 'select', required: true, value: '', valid: true},
					{label: 'City', key: 'city', type: 'text', required: true, value: '', valid: true},
					{label: 'Postal Code', key: 'zip', type: 'text', required: true, value: '', valid: true}
				],
				default: false,
				regions: false,
				country: false
			},
			newPaymentMethodError: false,
			isChange: false
		},
		created: function(){
			this.getSubscriptions()
		},
		methods: {
			getSubscriptions: function(){
				var postObj = {
					members: {
						subscriptions: 0
					}
				};
				$.post(tf.nexusUrl(), postObj).done(this.setupSubscriptions)
			},
			setupSubscriptions: function(data){
				var hasSubs = false;
				for(type in data.members.subscriptions.result){
					var subs = data.members.subscriptions.result[type];
					if(subs){
						if(subs.length) hasSubs = true;
						subs.forEach(function(sub){
							sub.loading = false;
							if(sub.label == 'All Access') sub.label = 'All Access'
							if(sub.expires) sub.expirationDate = new Date(sub.expires * 1000).toLocaleDateString('en-US', {month: '2-digit', day: '2-digit', year: 'numeric'})
						});
					}
				}
				hasSubs ? this.subscriptions = data.members.subscriptions.result : this.noSubs = true
			},
			cancelSubscription: function(subscription, type){
				this.currentSubscription = subscription;
				this.currentType = type;
				this.cancelSubscriptionModal = true;
			},
			cancelChannelSubscription: function(subscription){
				this.cancelSubscriptionModal = false;
				var postObj = {
					members: {
						subscriptions: {
							channels: {
								unsubscribe: {
									channel_id: this.currentSubscription.channel_id
								}
							}
						}
					}
				}
				this.subscriptions = false;
				this.noSubs = false;
				$.post(tf.nexusUrl(), postObj).done(this.setupSubscriptions);
			},
			cancelAASubscription: function(){
				this.cancelSubscriptionModal = false;
				var postObj = {
					members: {
						subscriptions: {
							aa: {
								unsubscribe: 1
							}
						}
					}
				};
				this.subscriptions = false;
				this.noSubs = false;
				$.post(tf.nexusUrl(), postObj).done(this.setupSubscriptions);
			},
			cancelPrivateLessonSubscription: function(){
				this.cancelSubscriptionModal = false;
				var postObj = {
					members: {
						subscriptions: {
							private_lessons: {
								unsubscribe: {
									id: this.currentSubscription.id
								}
							}
						}
					}
				};
				this.subscriptions = false;
				this.noSubs = false;
				$.post(tf.nexusUrl(), postObj).done(this.setupSubscriptions);
			},
			renewSubscription: function(subscription, type, isChange){
				this.newPaymentMethodForm.visible = false;
				this.newPaymentMethodForm.fields.forEach(function(field){
					field.value = '';
				});
				this.isChange = isChange ? true : false;
				this.currentSubscription = subscription;
				this.currentType = type;
				this.renewSubscriptionModal = true;
				var postObj = {
					members: {
						billing: 0
					}
				}, thisObj = this;
				$.post(tf.nexusUrl(), postObj).done(function(data){
					if(data.members.billing.result) thisObj.billingOptions = data.members.billing.result
				});
			},
			renewChannelSubscription: function(){
				this.renewSubscriptionModal = false;
				var postObj = {
					members: {
						subscriptions: {
							channels: {
								resubscribe: {
									channel_id: this.currentSubscription.channel_id,
									paymentid: this.currentSubscription.payment_profile.id
								}
							}
						}
					}
				}
				this.subscriptions = false;
				this.noSubs = false;
				$.post(tf.nexusUrl(), postObj).done(this.setupSubscriptions);
			},
			renewAASubscription: function(){
				this.renewSubscriptionModal = false;
				var postObj = {
					members: {
						subscriptions: {
							aa: {
								resubscribe: {
									paymentid: this.currentSubscription.payment_profile.id
								}
							}
						}
					}
				}
				this.subscriptions = false;
				this.noSubs = false;
				$.post(tf.nexusUrl(), postObj).done(this.setupSubscriptions);
			},
			renewPrivateLessonSubscription: function(){
				this.renewSubscriptionModal = false;
				var postObj = {
					members: {
						subscriptions: {
							private_lessons: {
								resubscribe: {
									id: this.currentSubscription.id,
									paymentid: this.currentSubscription.payment_profile.id
								}
							}
						}
					}
				};
				this.subscriptions = false;
				this.noSubs = false;
				$.post(tf.nexusUrl(), postObj).done(this.setupSubscriptions);
			},
			useProfile: function(item){
				if(item.billing_agreement){
					this.currentSubscription.payment_profile = {
						id: item.billing_agreement
					}
					// this.currentSubscription.payment_profile.id = item.id ? item.id : item.billing_agreement;
				} else this.currentSubscription.payment_profile = item
			},
			checkCountry: function(){
				var thisObj = this, hasValue = false;
				this.newPaymentMethodForm.fields.forEach(function(field){
					if(field.label.toLowerCase() == 'country' && field.value){
						hasValue = true;
						thisObj.newPaymentMethodForm.country = tf.countries[field.value];
					}
					else if(field.label.toLowerCase() == 'region') field.value = '';
				});
				this.newPaymentMethodForm.regions = hasValue ? this.newPaymentMethodForm.country.regions : false;
			},
			addNewPaymentProfile: function(){
				var postObj = {}, isValid = true, thisObj = this;
				var tempOptions = this.billingOptions
				this.billingOptions = false;
				this.newPaymentMethodForm.fields.forEach(function(field){
					field.valid = true;
					postObj[field.key] = field.value;
					if(field.required && !field.value){
						field.valid = false;
						isValid = false;
					}
				});
				postObj.default = this.newPaymentMethodForm.default
				this.newPaymentMethodError = false
				if(isValid){
					var postObj = {members: {billing: {cc: {add: postObj}}}};
					thisObj.newPaymentMethodForm.visible = false;
					$.post(tf.nexusUrl(), postObj).error(function(err, data){
						var tempErr = JSON.parse(err.responseText).errors.message
						thisObj.newPaymentMethodError = tempErr
						thisObj.billingOptions = tempOptions
					}).done(function(data){
						var postObjBilling = {
							members: {
								billing: 0
							}
						};
						$.post(tf.nexusUrl(), postObjBilling).done(function(data){
							if(data.members.billing.result) thisObj.billingOptions = data.members.billing.result;
						});
					});
				}
			}
		}
	});
});
});
</script>
