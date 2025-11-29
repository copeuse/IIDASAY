
// by snflrwfld.neocities.org


const charButtonsDiv = document.getElementById("charButtonsDiv");
const smileyDiv = document.getElementById("smileyDiv");

const addSpaceButton = document.getElementById("addSpaceButton");
const rerollButton = document.getElementById("rerollButton");
const clearButton = document.getElementById("clearButton");

const useSeedButton = document.getElementById("useSeedButton");
const seedInput = document.getElementById("seedInput");
const seedValueSpan = document.getElementById("seedValueSpan");


const copyButton = document.getElementById("copyButton");

function addCharButton(i) {
	let b = document.createElement("BUTTON");

	b.innerHTML = "&#"+i+";";
	b.value = i;
	b.className = "charButtonClass";
	b.addEventListener("click", () => {
		smileyDiv.innerHTML += b.innerHTML;
		//console.log(i); //TODO
	});

	charButtonsDiv.appendChild(b);
}


function showAllCharacters() {
	charButtonsDiv.innerHTML = "";

	for (i=0x0020;i<0x007F;i++) {
		addCharButton(i);	
	}
}


// RNG FUNCTIONS
let seedstr = "";


const WORDS = "dessein,marge,marquants,telle,concevoir,mesure,petit,comme,regimbant,contre,commune,monde,comme,celui,rapprochements,primant,autre,essor,accords,comme,feraient,alors,encore,rapides,faits,valeur,doute,absolument,violemment,genre,suspectes,faire,passer,Vierge,toile,chose,serait,monde,scintillante,faits,constatation,chaque,toutes,apparences,puisse,answer,question,Digital,artists,exploit,their,digital,materials,round,metaphorically,critically,glitches,static,personal,exploration,narrative,element,often,reflects,critically,people,starting,constant,state,think,become,apparent,genre,image,files,contain,minimally,processed,image,sensor,either,digital,image,motion,picture,scanner".split(',');


// https://stackoverflow.com/questions/521295/seeding-the-random-number-generator-in-javascript
function makeStrCode() {
	const nbWords = Math.floor(Math.random()*4)+2;
	let res = "";
	for (let i=0;i<nbWords;i++) {
		let w = WORDS[Math.floor(Math.random() * WORDS.length)];
		if (i===0) {
			w = w.slice(0,1).toLowerCase() + w.slice(1);
		}
		else{
			w = w.slice(0,1).toUpperCase() + w.slice(1);
		}
		res += w;
	}
	return res;
}


// https://stackoverflow.com/questions/521295/seeding-the-random-number-generator-in-javascript
function cyrb128(str) {
    let h1 = 1779033703, h2 = 3144134277,
        h3 = 1013904242, h4 = 2773480762;
    for (let i = 0, k; i < str.length; i++) {
        k = str.charCodeAt(i);
        h1 = h2 ^ Math.imul(h1 ^ k, 597399067);
        h2 = h3 ^ Math.imul(h2 ^ k, 2869860233);
        h3 = h4 ^ Math.imul(h3 ^ k, 951274213);
        h4 = h1 ^ Math.imul(h4 ^ k, 2716044179);
    }
    h1 = Math.imul(h3 ^ (h1 >>> 18), 597399067);
    h2 = Math.imul(h4 ^ (h2 >>> 22), 2869860233);
    h3 = Math.imul(h1 ^ (h3 >>> 17), 951274213);
    h4 = Math.imul(h2 ^ (h4 >>> 19), 2716044179);
    h1 ^= (h2 ^ h3 ^ h4), h2 ^= h1, h3 ^= h1, h4 ^= h1;
    return [h1>>>0, h2>>>0, h3>>>0, h4>>>0];
}

// https://stackoverflow.com/questions/521295/seeding-the-random-number-generator-in-javascript
function splitmix32(a) {
 return function() {
   a |= 0;
   a = a + 0x9e3779b9 | 0;
   let t = a ^ a >>> 16;
   t = Math.imul(t, 0x21f0aaad);
   t = t ^ t >>> 15;
   t = Math.imul(t, 0x735a2d97);
   return ((t = t ^ t >>> 15) >>> 0) / 4294967296;
  }
}

function testRand() {
	let rng = splitmix32(111111);
	for (let i=0; i<10; i++) {
		console.log(rng());
	}
}



const CHAR_NUM = 100;
const CHAR_MIN_RUN_LENGTH = 1;
const CHAR_MAX_RUN_LENGTH = 5;
const CHAR_MIN_INDEX = 0x0020;
const CHAR_MAX_INDEX = 0x2FA1F;

// https://jrgraphix.net/research/unicode_blocks.php
const CHAR_RANGES = [
	[0x0020, 0x007F],
	[0x00A0, 0x00FF],
	[0x0100, 0x017F],
	[0x0180, 0x024F],
	[0x0250, 0x02AF],
	[0x02B0, 0x02FF],
	[0x0300, 0x036F],
	[0x0370, 0x03FF],
	[0x0400, 0x04FF],
	[0x0500, 0x052F],
	[0x0530, 0x058F],
	[0x0590, 0x05F4],
	[0x600, 0x6FF],
	[0x700, 0x74F],
	[0x780, 0x7BF],
	[0x900, 0x97F],
	[0x980, 0x9FD],
	[0xA00, 0xA75],
	[0xA80, 0xAF1],
	[0xB00, 0xB77],
	[0xB80, 0xBFA],
	[0xC00, 0xC7F],
	[0xC80, 0xCF2],
	[0xD00, 0xD7F],
	[0xD80, 0xDDF],
	[0xE00, 0xE5B],
	[0xE80, 0xEDD],
	[0xF00, 0xFDA],
	[0x1000, 0x109F],
	[0x10A0, 0x10FF],
	[0x1100, 0x11F9],
	[0x1200, 0x137C],
	[0x13A0, 0x13FF],
	[0x13A0, 0x13F5],
	[0x1400, 0x167F],
	[0x1680, 0x169C],
	[0x16A0, 0x16F0],
	[0x1700, 0x1715],
	[0x1720, 0x1737],
	[0x1740, 0x1753],
	[0x1760, 0x1770],
	[0x1780, 0x17F9],
	[0x1800, 0x18AA],
	[0x1900, 0x194F],
	[0x1950, 0x1974],
	[0x19E0, 0x19FF],
	[0x1D00, 0x1D7F],
	[0x1E00, 0x1EFF],
	[0x1F00, 0x1FFF],
	[0x2000, 0x205E],
	[0x2070, 0x209F],
	[0x20A0, 0x20BF],
	[0x20D0, 0x20F0],
	[0x2100, 0x214F],
	[0x2150, 0x2186],
	[0x2190, 0x21FF],
	[0x2200, 0x22FF],
	[0x2300, 0x23FF],
	[0x2400, 0x2426],
	[0x2440, 0x244A],
	[0x2460, 0x24FF],
	[0x2500, 0x257F],
	[0x2590, 0x259F],
	[0x25A0, 0x25FF],
	[0x2600, 0x26FF],
	[0x27C0, 0x27EF],
	[0x27F0, 0x27FF],
	[0x2800, 0x28FF],
	[0x2900, 0x297F],
	[0x2980, 0x29FF],
	[0x2A00, 0x2AFF],
	[0x2B00, 0x2B55],
	[0x2E80, 0x2EF3],
	[0x2F00, 0x2FDF],
	[0x2FF0, 0x2FFF],
	[0x3000, 0x303F],
	[0x3041, 0x309F],
	[0x30A0, 0x30FF],
	[0x30A0, 0x30FF],
	[0x3105, 0x312F],
	[0x3131, 0x318E],
	[0x3190, 0x319F],
	[0x31A0, 0x31B7],
	[0x31F0, 0x31FF],
	[0x31F0, 0x31FF]

	// TODO

]

function showRandomCharacters() {
	charButtonsDiv.innerHTML = "";

	// RNG seeding
	const rng = splitmix32(cyrb128(seedstr)[0]);


	let totalCharNum = 0;

	//while (totalCharNum < CHAR_NUM) {
	for (let i=0; i<100; i++){
		let selectedRangeIndex = Math.floor(rng() * CHAR_RANGES.length); // TODO
		let selectedRangeMin = CHAR_RANGES[selectedRangeIndex][0];
		let selectedRangeMax = CHAR_RANGES[selectedRangeIndex][1];

		let beginIndex = Math.floor(rng() * (selectedRangeMax - selectedRangeMin)) + selectedRangeMin; // TODO
		let runLength = Math.floor(rng() * (CHAR_MAX_RUN_LENGTH - CHAR_MIN_RUN_LENGTH)) + CHAR_MIN_RUN_LENGTH; // TODO

		if (beginIndex + runLength > selectedRangeMax) {
			runLength = selectedRangeMax - beginIndex;
		}

		for (let i=0; i<runLength; i++) {
			addCharButton(beginIndex + i);
			//console.log(beginIndex + i);
		}

		totalCharNum += runLength;
		if (totalCharNum >= CHAR_NUM) {
			break;
		}
	}
}

function onLoad() {
	seedstr = makeStrCode();
	seedValueSpan.innerHTML = seedstr;
	showRandomCharacters();
}


// BUTTON LISTENERS

addSpaceButton.addEventListener("click", () => {
	smileyDiv.innerHTML += "&nbsp;";
});

rerollButton.addEventListener("click", () => {
	seedstr = makeStrCode();
	seedValueSpan.innerHTML = seedstr;
	showRandomCharacters();
});

useSeedButton.addEventListener("click", () => {
	seedstr = seedInput.value;
	seedValueSpan.innerHTML = seedstr;
	showRandomCharacters();
})

clearButton.addEventListener("click", () => {
	smileyDiv.innerHTML = "";
});

copyButton.addEventListener("click", () => {
	navigator.clipboard.writeText(smileyDiv.value);
});
