var welcome = {};

// --------------  things that vary from task to task --------------

welcome.task = {};
welcome.task.blurb = '<b>"Study name"</b> is a short psychological study investigating how people make decisions.';
welcome.task.time = '15-20 minutes';
welcome.task.pay = 'US$0.85';

// --------------  things that vary between ethics approvals --------------

welcome.ethics = {};
welcome.ethics.approval = '2574';
welcome.ethics.name = 'Theories of inductive reasoning';
welcome.ethics.selection = 'You are invited to participate in a study of how human reasoning works.  We hope to learn what information people find most useful in guiding their judgments about the world. You were selected as a possible participant in this study because of your enrolment in psychology at UNSW.';
welcome.ethics.description = 'If you decide to participate, we will present you with some reasoning problems in which you need to use the (possibly incomplete) information to make judgements (or guesses) about the truth of different propositions. Detailed instructions will be provided once the task begins. The exact number of problems you need to solve depends on which version of the task the computer assigns you to, but the on-screen display will inform you of how much further you have to go. The task should take approximately ' + welcome.task.time + ' to complete including reading time.';


// ----------------------- function to start the task ------------------
welcome.run = function() { 
    document.getElementById("welcome").innerHTML =
        welcome.section.header + 
        welcome.section.start + 
        welcome.section.consent +
        welcome.section.demographics;
}

// ------------- actions to take at the end of each click ----------------
welcome.click = {};
welcome.click.start = function() {
    welcome.helpers.setDisplay('start', 'none');
    welcome.helpers.setDisplay('consent', '');
    welcome.helpers.setHeader(' ');   
}
welcome.click.consent = function() {
    jsPsych.data.addProperties({
        consent: "yes"
    })
    welcome.helpers.setDisplay('consent', 'none');
    welcome.helpers.setDisplay('demographics', '');
    welcome.helpers.setHeader(' ');
}
welcome.click.nonconsent = function() {
    jsPsych.data.addProperties({
        consent: "no"
    })
    welcome.helpers.setDisplay('consent', 'none');
    welcome.helpers.setDisplay('demographics', '');
    welcome.helpers.setHeader(' ');
}
welcome.click.demographics = function() {
    welcome.helpers.setDisplay('demographics', 'none');
    welcome.helpers.setDisplay('header', 'none');
    jsPsych.data.addProperties({  // record the condition assignment in the jsPsych data
        gender: welcome.helpers.getRadioButton("gender"),
        age: document.getElementById("age").value
    });
    startExperiment(); // start the jsPsych experiment
}


// ------------- html for the various sections ----------------
welcome.section = {};
welcome.section.header =
    '<!-- ####################### Heading ####################### -->' +
    '<a name="top"></a>' +
    '<h1 style="text-align:center; width:1200px" id="header" class="header">' +
    '   &nbsp; UNSW Computational Cognitive Science</h1>';

welcome.section.start =
    '<!-- ####################### Start page ####################### -->' +
    '<div class="start" style="width: 1000px">' +
    '<div class="start" style="text-align:left; border:0px solid; padding:10px;' +
    '                          width:800px; float:right; font-size:90%">' +
    "In this week's tutorial we'll go through a very brief inductive reasoning task, one that is connected to some of the content from Dani Navarro's lectures, and then go through a short data analysis exercise. The idea is to give you a sense of how real research in this area works, and how the data from these experiments can be analysed." + 
    "In fact, the exercise that we're going to cover is closely connected with an ongoing research project into human reasoning. With that in mind, we'd like to request your consent to include your responses as part of our project, so the task starts out with a consent form. We'd definitely appreciate it if you do agree to participate, but your are under no obligation at all to do so - if you choose not to agree, the task will proceed as normal because the tutorial is built around it, but your data won't be retained as part of the project. It's totally up to you." + 
    '<!-- Next button for the splash page -->' +
    '<p align="center"> <input type="button" id="splashButton" class="start jspsych-btn" ' +
    'value="Start!" onclick="welcome.click.start()"> </p>' +
    '</div>' +
    '</div>';

welcome.section.consent =
    '	<!-- ####################### Consent ####################### -->' +
    '	<div class="consent" style="display:none; width:1000px">' +
    '		<!-- Text box for the splash page -->' +
    '		<div class="consent" style="text-align:left; border:0px solid; padding:10px;  width:800px; font-size:90%; float:right">' +
    '			<p align="right">Approval No ' + welcome.ethics.approval + '</p>' +
    '			<p align="center"><b>THE UNIVERSITY OF NEW SOUTH WALES<br>' +
    '			PARTICIPANT INFORMATION STATEMENT</b><br><br>' + welcome.ethics.name + '</p>' +
    '			<p><b>Participant Selection and Purpose of Study</b></p>' +
    '			<p>' + welcome.ethics.selection + '</p>' +
    '			<p><b>Description of Study and Risks</b></p>' +
    '			<p>' + welcome.ethics.description + '</p>' +
    '			<p>No discomforts or inconveniences besides some boredom are reasonably expected. No risks are reasonably expected as a result of your participation in this study. We cannot and do not guarantee or promise that you will receive any benefits from this study.</p>' +
    '			<p><b>Confidentiality and Disclosure of Information</b></p>' +
    '			<p>Any information that is obtained in connection with this study and that can be identified with you will remain confidential and will be disclosed only with your permission or except as required by law.  If you give us your permission by clicking on the "I agree" button below, we plan to publish the results in academic journals and discuss the results at scientific conferences. In any publication, information will be provided in such a way that you cannot be identified.</p>' +
    '			<p><b>Recompense to participants</b></p>' +
    '			<p>There is no recompence for participation.' +
    '			<p><b>Your consent</b></p>' +
    '			<p>Your decision whether or not to participate will not prejudice your future relations with The University of New South Wales.  If you decide to participate, you are free to withdraw your consent and to discontinue participation at any time without prejudice.</p>' +
    '			<p><b>Inquiries</b></p>' +
    '			<p>If you have any questions or concerns following your participation, Associate Professor Daniel Navarro (+61 4 2148 8402, email. d.navarro@unsw.edu.au) will be happy to address them. Complaints about the study may be directed to UNSW&#8217;s Research Ethics and Compliance Support, (phone +61 2 9385 4235 or +61 2 9385 4958, email. humanethics@unsw.edu.au).<p> ' +
    '			<p>Please keep a copy of this information sheet (you can download the pdf <a href="./wtf/info.pdf" target="_blank">here</a>)</p>' +
    '			<br>' +
    '			<p align="center"><b>PARTICIPANT CONSENT</b></p>' +
    '			By continuing, you are making a decision whether or not to participate.  Clicking the button below indicates that, having read the information provided on the participant information sheet, you have decided to participate.' +
    '			<br>' +
    '			<p align="center">' +
    '           <input type="button" id="consentButton" class="consent jspsych-btn" value="I agree" onclick="welcome.click.consent()" >' +
    '			</p>' +
    '			<p>To withdraw your consent, click on the button below (Note that you will also get a second opportunity to withdraw your consent at the end of the task should you change your mind). The task will continue because it is part of the class you are enrolled in, but your responses will not be retained.</p>' +
    '			<p align="center">' +
    '           <input type="button" id="nonConsentButton" class="consent jspsych-btn" value="I do not agree" onclick="welcome.click.nonconsent()" >' +
    '		</div><br><br></div>';
    
welcome.section.demographics = 
 '	<!-- ####################### Demographics ####################### -->' +
    '	<div class="demographics" style="display:none; align:center; width: 1000px">' +
    '		<div class="demographics" style="text-align:left; border:0px solid; padding:10px;  width:800px; font-size:90%; float:right">' +
    '			<!-- Explanatory text -->' +
    '            <p font-size:110%><b>Demographic information:</b></p>' +
    '			<!-- Gender -->' +
    '           <label for="gender"><b>Gender: &nbsp;</b></label>' +
    '           <input type="radio" name="gender" value="male" /> Male &nbsp; ' +
    '           <input type="radio" name="gender" value="female" /> Female &nbsp;' +
    '           <input type="radio" name="gender" value="other" /> Other<br /><br />' +
    '			<!-- Age -->' +
    '           <label for="age"><b>Age: &nbsp;</b></label><input id="age" name="age" /><br /><br />' +
    '		<!-- Demographics  button -->' +
    '        <p align="center">' +
    '                <input type="button" class="demographics jspsych-btn"' +
    '                        id="demographicsButton" value="Next >"' +
    '                       onclick="welcome.click.demographics()">' +
    '       </p></div>';



// ----------------------- helper functions ------------------

welcome.helpers = {};
welcome.helpers.getRadioButton = function(name) { // get the value of a radio button
    var i, radios = document.getElementsByName(name);
    for (i = 0; i < radios.length; i = i + 1) {
        if (radios[i].checked) {
            return (radios[i].value);
        }
    }
    return ("NA");
}
welcome.helpers.setDisplay = function(theClass, theValue) { // toggle display status
    var i, classElements = document.getElementsByClassName(theClass);
    for (i = 0; i < classElements.length; i = i + 1) {
        classElements[i].style.display = theValue;
    }
}
welcome.helpers.setVisibility = function(theClass, theValue) { // toggle visibility
    var i, classElements = document.getElementsByClassName(theClass);
    for (i = 0; i < classElements.length; i = i + 1) {
        classElements[i].style.visibility = theValue;
    }
}
welcome.helpers.setHeader = function(theValue) { // alter the header
    document.getElementById("header").innerText = theValue;
}










