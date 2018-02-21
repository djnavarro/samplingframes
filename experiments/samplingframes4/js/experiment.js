/*jslint sloppy: true */

// define globals
var data;
var state, counter, sampling, frequency, samplesize, ss;
var tic, toc;
var nInstruct, instruct, nQuestions;


// instructions 
nInstruct = 3;
instruct = 1;
nQuestions = 3;


// uniform integer greater than or equal to a AND less than b
function randomInteger(a, b) {
    // "use strict";
	return (Math.floor((Math.random() * (b - a)) + a));
}

// permute all elements of an array [THIS IS THE CORRECTED VERSION!!!]
// requires: randomInteger, Array.prototype.swap
Array.prototype.permute = function () {
    // "use strict";
    var i, j = 0;
	for (i = 0; i <= this.length - 2; i = i + 1) { // loop over positions
        j = randomInteger(i, this.length); // index of a random position >= i
	    this.swap(i, j);
	}
	return (this);
};

// swap two elements of an array
Array.prototype.swap = function (x, y) {
    // "use strict";
    var b = this[x];
    this[x] = this[y];
    this[y] = b;
    return (this);
};

// initialise data
data = {};

// generate the condition
sampling = randomInteger(0, 2);
ss = randomInteger(0, 3);

// initial state for the experiment
state = "intro";
counter = 1;

// store condition
if (sampling === 0) {
	data.sampling = "category";
} else {
	data.sampling = "property";
}

if (ss === 0) {
	samplesize = 3;
} else if (ss === 1) {
	samplesize = 8;
} else {
    samplesize = 20;
}
data.samplesize = samplesize;

data.testorder = [1, 2, 3, 4, 5, 6].permute();
data.responses = [];
data.questions = ["small bird", "large bird", "small reptile",
                  "large reptile", "small mammal", "large mammal"];
data.freeresponse = [];

// the boring bits
data.startTime = Date.now();
data.stopTime = 0;
data.unloadAttempts = 0; // idle curiosity: does anyone really try to leave?
data.gender = [];
data.age = [];
data.turkcode = Math.floor(Math.random() * 89999999) + 10000000; // generate completion code
data.withdraw = 0;

data.instructionFails = 0; // how many times did they fail the check?
data.instructionTime = []; // track how long they looked at the instructions
data.instructionCheckScore = []; // how many questions did they get right each time?
data.language = [];
data.country = [];

// set the completion code
document.getElementById('turkcode').innerHTML = data.turkcode.toString();

// function writing data to disk
function writeData() {

    // wrap the data writing event in an anonymous function to make sure 
    // it executes before we move to the next trial
    (function () {
        var dataString = JSON.stringify(data);
        //console.log(dataString);
        //$.post('submit', {"content": dataString});
    }());
}

	
// ------------ functions: generic UI helpers -------------

// move to the specified location
function scrollTo(hash) {
    location.hash = "#" + hash;
}

// get the value of a radio button
function getRadioButton(name) {
	var i, radios = document.getElementsByName(name);
	for (i = 0; i < radios.length; i = i + 1) {
	    if (radios[i].checked) {
	        return (radios[i].value);
		}
	}
}

// function to change the display property of a set of objects
function setDisplay(theClass, theValue) {
	var i, classElements = document.getElementsByClassName(theClass);
	for (i = 0; i < classElements.length; i = i + 1) {
		classElements[i].style.display = theValue;
	}
}

// function to change the visibility property of a set of objects
function setVisibility(theClass, theValue) {
	var i, classElements = document.getElementsByClassName(theClass);
	for (i = 0; i < classElements.length; i = i + 1) {
		classElements[i].style.visibility = theValue;
	}
}

// set the focus
function setFocus(theElement) {
	document.getElementById(theElement).focus();
}

// alter the header
function setHeader(theValue) {
	document.getElementById("header").innerText = theValue;
}

// alter the border (on one of the instruction boxes)
function setBoxBorder(whichBox, theValue) {
	document.getElementById('instruction' + whichBox + 'inner').style.border = theValue;
}

// clear all the check marks for the radio buttons 
function clearCheckRadio() {
	var i, radios = document.getElementsByClassName('checkRadio');
	for (i = 0; i < radios.length; i = i + 1) {
		radios[i].checked = false;
	}
}

// ------------- handle the introductory stuff ----------------

function splashButtonClick() {
	setDisplay('start', 'none');
	setDisplay('consent', '');
	setHeader('Consent Form');
}

function consentButtonClick() {
	setDisplay('consent', 'none');
	setDisplay('demographics', '');
	setHeader('Demographics');
}

function nonconsentButtonClick() {
    data.withdraw = 1;
	setDisplay('consent', 'none');
	setDisplay('demographics', '');
	setHeader('Demographics');
}


function demographicsButtonClick() {
	setDisplay('demographics', 'none');
	setHeader('');
    
    data.gender = getRadioButton("gender");
	data.age = document.getElementById("age").value;
    data.language = document.getElementById("language").value;
    data.country = document.getElementById("country").value;

	// writeData();
	
    setDisplay('instruction', '');
	setFocus('instructionButton');
	tic = Date.now(); // start timer [see ***]
    
}


function instructionButtonClick() {
    var i = instruct;
	if (i === (nInstruct - 1)) { // change the text when we first reach last instruction
		document.getElementById("instructionButton").value = "Check your knowledge!";
	}
    
	if (i >= nInstruct) { // if all instructions are revealed, move along
		setDisplay('instruction', 'none');
		setDisplay('check', '');
		setHeader('Check Your Knowledge!');
		toc = Date.now(); // see [***]
        
	} else { // reveal next instruction if needed
        setDisplay('instruction' + i, '');
        scrollTo('instruct' + i);
        setBoxBorder(i - 1, '2px dotted grey');
	}
	instruct = instruct + 1;
}

function checkButtonClick() {
    var val, nCorrect = 0, q;
	setDisplay('check', 'none');
	
    // count the number of correct responses
	for (q = 0; q < nQuestions; q = q + 1) {
		val = getRadioButton("question" + q);
		if (val === "correct") {
            nCorrect = nCorrect + 1;
        }
	}
	
	// store the time taken and the score
	data.instructionTime[data.instructionFails] = toc - tic;
	data.instructionCheckScore[data.instructionFails] = nCorrect;
    
    // if everything is correct, move on
    if (nCorrect === nQuestions) {
        setHeader('Correct!');
		setDisplay('checkSuccess', '');
		setFocus('checkSuccessButton');
        
    // otherwise send them back
    } else {
        data.instructionFails = data.instructionFails + 1;
        clearCheckRadio();
		setHeader('Please Try Again!');
		setDisplay('checkFail', '');
		setFocus('checkFailButton');
    }
}

function checkSuccessButtonClick() {
	setDisplay('header', '');
    setHeader('');
	setDisplay('checkSuccess', 'none');
	setDisplay('expt', '');
}

function checkFailButtonClick() {
	setDisplay('checkFail', 'none');
    setBoxBorder(nInstruct - 1, '2px dotted grey');
	setDisplay('instruction', '');
	setHeader('Instructions');
	setFocus('instructionButton');
	scrollTo('top');
	tic = Date.now();
}



function updateDisplay() {
    
    var imgstr, ind;
    if (state === "intro") {
        imgstr = "./img/intro" + counter + ".png";
    }
    
    if (state === "sample") {
        if (sampling === 0) { // category sampling
            if (counter <= 2) {
                imgstr = "./img/category" + counter + ".png"; // intro slides
            } else {
                imgstr = "./img/category_n" + samplesize + "_" + (counter - 2) + ".png"; // intro slides
            }
        } else { // property sampling
            
            if (counter <= 2) {
                imgstr = "./img/property" + counter + ".png";
            } else {
                imgstr = "./img/property_n" + samplesize + "_" + (counter - 2) + ".png"; // intro slides
            }
        }
    }

    if (state === "test") {
        if (counter > 1) {
            setDisplay('expt', 'none');
            setTimeout(function () {setDisplay('expt', ''); }, 500);
            ind = data.testorder[counter - 2] + 1;
            imgstr = "./img/generalisation" + ind + ".png";
        } else {
            imgstr = "./img/generalisation1.png";
        }
        
    }
    document.getElementById("exptpic").src = imgstr;
}
 

function exptNextButtonClick() {
    
    var oldstate = state;
    
    // there are 3 intro slides
    if (oldstate === "intro" && counter === 3) {
        state = "sample";
        counter = 0;
    }
    
    // there are 4 sampling slides (2 intro and 2 data)
    if (oldstate === "sample" && counter === 4) {
        state = "test";
        counter = 0;
    }
    
    if (oldstate === "test") {
        setTimeout(function () {document.getElementById("responsebuttons").style.display = ""; }, 3000);
        document.getElementById("responsebuttons").style.display = "none";
        document.getElementById("exptNext").style.display = "none";
    } else {
        setTimeout(function () {document.getElementById("exptNext").style.display = ""; }, 3000);
        document.getElementById("exptNext").style.display = "none";
    }
    
    // there are 7 test slides
    if (oldstate === "test" && counter === 7) {
        setDisplay('expt', 'none');
        setDisplay('postexpt', '');
    }
    
    document.getElementById("exptNext").blur();
    counter = counter + 1;
    if (counter < 8) {
        updateDisplay();
    }
}


function buttonPress(resp) {
    data.responses[data.testorder[counter - 2] - 1] = resp;
    exptNextButtonClick();
    document.getElementById("button" + resp).blur();
}

function withdraw() {
    data.withdraw = 1;
    document.getElementById("withdrawbutton").style.display = "none";
    document.getElementById("endmsg").innerHTML = "Your data will not be recorded. You can close the browser window and wait for the tutorial to continue!";
    document.getElementById("endmsg2").innerHTML = "";
    writeData();
}

function goToEnd() {
    // write data!!!!
	data.freeresponse = document.getElementById("postreflect").value;
	data.stopTime = Date.now();
	writeData();
	
    setHeader('Done!');
    setDisplay('postexpt', 'none');
    setDisplay('end', '');
}



// ------------- other  ------------- 


//window.onbeforeunload = function (e) {
//	
//    var message;
//    e = e || window.event;
//    message = "You are about to leave this page, but have not yet finished the task!";
//    
//    data.unloadAttempts = data.unloadAttempts + 1;
//    
//    // For IE and Firefox
//    if (e) {
//        e.returnValue = message;
//    }
//
//    // For Safari
//    return message;
//};

// JUMP TO STATE
//setDisplay('start', 'none');
//setDisplay('header', 'none');
//setDisplay('postexpt', '');

