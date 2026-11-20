const fs = require('fs');
const path = require('path');

const content = fs.readFileSync('c:/Users/Lenovo/Documents/Mobile JAVARA/Javara/assets/clean_section_4.js', 'utf8');
const lines = content.split('\n');

// Part A: lines 0 to 286
const partA = lines.slice(0, 287).join('\n') + '\nreturn "Section 4A created!";\n';
fs.writeFileSync('c:/Users/Lenovo/Documents/Mobile JAVARA/Javara/assets/run_section_4a.js', partA, 'utf8');

// Part B needs helpers + find sec4
const helpers = lines.slice(0, 142).join('\n');
const partBCode = lines.slice(287).join('\n');
const partB = helpers + '\n' +
  'const javaraPage = figma.root.children.find(p => p.name === "Javara");\n' +
  'const sec4 = javaraPage.children.find(c => c.name && c.name.startsWith("ALUR 4"));\n' +
  'let s4x = 60 + 492 * 4;\n' +
  'const y4Pos = 80;\n' +
  partBCode;
fs.writeFileSync('c:/Users/Lenovo/Documents/Mobile JAVARA/Javara/assets/run_section_4b.js', partB, 'utf8');

console.log('Done splitting! 4A:', partA.length, '4B:', partB.length);
