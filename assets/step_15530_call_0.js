const page2 = figma.root.children.find(p => p.name === 'Page 2');
if (!page2) return "Page 2 not found";
// Let's inspect the top-level children of Page 2, their names, types, positions
return page2.children.map(c => ({
  id: c.id,
  name: c.name,
  type: c.type,
  x: c.x,
  y: c.y,
  width: c.width,
  height: c.height
})).sort((a,b) => a.x - b.x || a.y - b.y);