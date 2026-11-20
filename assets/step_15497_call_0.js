const javaraPage = figma.root.children.find(p => p.name === 'Javara');
return javaraPage.children.slice(17).map(c => ({ name: c.name, id: c.id }));