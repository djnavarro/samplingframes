/*jslint sloppy: true */

// define globals
var data;
var state, counter, sampling, frequency;
var tic, toc;

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
frequency = randomInteger(0, 2);

// initial state for the experiment
state = "intro";
counter = 1;

// store condition
if (sampling === 0) {
	data.sampling = "category";
} else {
	data.sampling = "property";
}

if (frequency === 0) {
	data.frequency = "smallworld";
} else {
	data.frequency = "largeworld";
}

data.testorder = [1, 2, 3, 4, 5, 6].permute();
data.responses = [];
data.questions = ["small bird", "large bird", "small reptile",
                  "large reptile", "small mammal", "large mammal"];

// the boring bits
data.startTime = Date.now();
data.stopTime = 0;
data.unloadAttempts = 0; // idle curiosity: does anyone really try to leave?
data.gender = [];
data.age = [];
data.turkcode = Math.floor(Math.random() * 89999999) + 10000000; // generate completion code
data.withdraw = 0;

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

	// writeData();
	
    setDisplay('expt', '');
	//setFocus('instructionButton');
	tic = Date.now(); // start timer [see ***]
}

function goToEnd() {
    // write data!!!!
    //data.experiment.memorycheck = getRadioButton("memcheck");
	//data.experiment.freeresponse = document.getElementById("postreflect").value;
	data.stopTime = Date.now();
	writeData();
	
    setHeader('Done!');
    setDisplay('postexpt', 'none');
    setDisplay('end', '');
}


function updateDisplay() {
    
    var imgstr, ind;
    if (state === "intro") {
        imgstr = "./img/intro" + counter + ".png";
    }
    
    if (state === "sample") {
        if (sampling === 0) {
            imgstr = "./img/category" + counter + ".png";
        } else {
            imgstr = "./img/property" + counter + ".png";
        }
    }
    if (state === "freq") {
        if (frequency === 0) {
            imgstr = "./img/smallworld" + counter + ".png";
        } else {
            imgstr = "./img/largeworld" + counter + ".png";
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
    
    if (oldstate === "intro" && counter === 2) {
        state = "freq";
        counter = 0;
    }
    
    if (oldstate === "freq" && counter === 3) {
        state = "sample";
        counter = 0;
    }
    
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
    
    if (oldstate === "test" && counter === 7) {
        setDisplay('expt', 'none');
        goToEnd();
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

