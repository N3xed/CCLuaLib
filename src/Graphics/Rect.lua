Rect = {}
function Rect.containsPoint(xRect, yRect, width, height, x, y)
  return (x >= xRect) and (x < (xRect + width)) and (y >= yRect) and (y < (yRect + height))
end