collision = { }
collision.check = function(collider, type, func)
  for shape, delta in pairs(collider) do
    if shape.colliderType == type then
      func(shape)
    end
  end
end
collision.update = function() end
