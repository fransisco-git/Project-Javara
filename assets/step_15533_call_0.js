try {
  const sec = figma.createSection();
  sec.name = "Test Section";
  sec.resize(1000, 1000);
  const id = sec.id;
  sec.remove();
  return { supported: true, id };
} catch (e) {
  return { supported: false, error: e.message };
}