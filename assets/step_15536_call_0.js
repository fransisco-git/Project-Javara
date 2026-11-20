const javaraPage = figma.root.children.find(p => p.name === 'Javara');
const toRemove = [...javaraPage.children];
for (const c of toRemove) {
  c.remove();
}
return `Cleared ${toRemove.length} old nodes from page Javara.`;