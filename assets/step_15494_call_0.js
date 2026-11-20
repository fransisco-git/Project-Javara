const javaraPage = figma.root.children.find(p => p.name === 'Javara');
return javaraPage.children.map((c, i) => `${i + 1}. ${c.name} (x:${c.x}, y:${c.y}, w:${c.width}, h:${c.height})`);