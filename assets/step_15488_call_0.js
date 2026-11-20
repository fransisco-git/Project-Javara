const javaraPage = figma.root.children.find(p => p.name === 'Javara');
return javaraPage.children.map(c => ({ id: c.id, name: c.name, x: c.x, y: c.y, width: c.width, height: c.height }));