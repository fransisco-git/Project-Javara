const javaraPage = figma.root.children.find(p => p.name === 'Javara');
figma.viewport.scrollAndZoomIntoView(javaraPage.children);
return "Viewport zoomed to fit all 23 screens!";