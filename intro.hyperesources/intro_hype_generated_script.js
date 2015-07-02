//	HYPE.documents["intro"]

(function HYPE_DocumentLoader() {
	var resourcesFolderName = "intro.hyperesources";
	var documentName = "intro";
	var documentLoaderFilename = "intro_hype_generated_script.js";
	var mainContainerID = "intro_hype_container";

	// find the URL for this script's absolute path and set as the resourceFolderName
	try {
		var scripts = document.getElementsByTagName('script');
		for(var i = 0; i < scripts.length; i++) {
			var scriptSrc = scripts[i].src;
			if(scriptSrc != null && scriptSrc.indexOf(documentLoaderFilename) != -1) {
				resourcesFolderName = scriptSrc.substr(0, scriptSrc.lastIndexOf("/"));
				break;
			}
		}
	} catch(err) {	}

	// Legacy support
	if (typeof window.HYPE_DocumentsToLoad == "undefined") {
		window.HYPE_DocumentsToLoad = new Array();
	}
 
	// load HYPE.js if it hasn't been loaded yet
	if(typeof HYPE_160 == "undefined") {
		if(typeof window.HYPE_160_DocumentsToLoad == "undefined") {
			window.HYPE_160_DocumentsToLoad = new Array();
			window.HYPE_160_DocumentsToLoad.push(HYPE_DocumentLoader);

			var headElement = document.getElementsByTagName('head')[0];
			var scriptElement = document.createElement('script');
			scriptElement.type= 'text/javascript';
			scriptElement.src = resourcesFolderName + '/' + 'HYPE.js?hype_version=160';
			headElement.appendChild(scriptElement);
		} else {
			window.HYPE_160_DocumentsToLoad.push(HYPE_DocumentLoader);
		}
		return;
	}
	
	// handle attempting to load multiple times
	if(HYPE.documents[documentName] != null) {
		var index = 1;
		var originalDocumentName = documentName;
		do {
			documentName = "" + originalDocumentName + "-" + (index++);
		} while(HYPE.documents[documentName] != null);
		
		var allDivs = document.getElementsByTagName("div");
		var foundEligibleContainer = false;
		for(var i = 0; i < allDivs.length; i++) {
			if(allDivs[i].id == mainContainerID && allDivs[i].getAttribute("HYPE_documentName") == null) {
				var index = 1;
				var originalMainContainerID = mainContainerID;
				do {
					mainContainerID = "" + originalMainContainerID + "-" + (index++);
				} while(document.getElementById(mainContainerID) != null);
				
				allDivs[i].id = mainContainerID;
				foundEligibleContainer = true;
				break;
			}
		}
		
		if(foundEligibleContainer == false) {
			return;
		}
	}
	
	var hypeDoc = new HYPE_160();
	
	var attributeTransformerMapping = {b:"i",c:"i",bC:"i",d:"i",aS:"i",M:"i",e:"f",aT:"i",N:"i",f:"d",O:"i",g:"c",aU:"i",P:"i",Q:"i",aV:"i",R:"c",bG:"f",aW:"f",aI:"i",S:"i",bH:"d",l:"d",aX:"i",T:"i",m:"c",bI:"f",aJ:"i",n:"c",aK:"i",bJ:"f",X:"i",aL:"i",A:"c",aZ:"i",Y:"bM",B:"c",bK:"f",bL:"f",C:"c",D:"c",t:"i",E:"i",G:"c",bA:"c",a:"i",bB:"i"};
	
	var resources = {"0":{n:"planeLg.png",p:1}};
	
	var scenes = [{x:0,p:"600px",c:"#0F2839",onSceneTimelineCompleteActions:[{type:1,transition:1,sceneSymbol:1}],v:{"3":{o:"content-box",h:"0",x:"visible",a:-82,q:"100% 100%",b:435,j:"absolute",r:"inline",c:62,k:"div",z:"2",d:58,aY:"0",f:"306deg"},"2":{aU:8,G:"#FFFFFF",c:555,aV:8,r:"inline",d:65,e:"0.000000",s:"AppleGothic,sans-serif",bL:"0.000000",t:24,Z:"break-word",w:"<span style=\"color: rgb(255, 255, 255); font-family: AppleGothic, sans-serif; text-align: center; background-color: rgb(15, 40, 57); \">On average, an airplane in the U.S. departs&nbsp;</span><div><span style=\"color: rgb(255, 255, 255); font-family: AppleGothic, sans-serif; text-align: center; background-color: rgb(15, 40, 57); \">4 times and flies&nbsp;</span><span style=\"background-color: rgb(15, 40, 57); color: rgb(255, 255, 255); font-family: AppleGothic, sans-serif; text-align: center; font-size: 24px; \">for a total of 10 hours each day.&nbsp;</span></div>",j:"absolute",x:"visible",k:"div",y:"preserve",z:"1",aS:8,aT:8,a:194,F:"center",b:369},"52":{aU:8,G:"#FFFFFF",c:55,aV:8,r:"inline",d:15,e:"1.000000",s:"AppleGothic,sans-serif",t:16,Z:"break-word",aP:"pointer",w:"<div>SKIP &gt;</div>",j:"absolute",x:"visible",aA:[{type:4,javascriptOid:"36"}],k:"div",y:"preserve",z:"3",aS:8,aT:8,a:866,F:"right",b:743}},n:"start",T:{kTimelineDefaultIdentifier:{d:8.14,i:"kTimelineDefaultIdentifier",n:"Main Timeline",a:[{f:"2",t:0,d:4.01,i:"a",e:449,s:-82,o:"3"},{f:"2",t:0,d:2,i:"b",e:253,s:435,o:"3"},{f:"2",t:0,d:3.29,i:"e",e:"0.000000",s:"0.000000",o:"2"},{f:"2",t:0.05,d:2.07,i:"f",e:"360deg",s:"306deg",o:"3"},{f:"2",t:2,d:2.01,i:"b",e:251,s:253,o:"3"},{f:"2",t:3.29,d:1.09,i:"e",e:"1.000000",s:"0.000000",o:"2"},{f:"2",t:5.08,d:1.29,i:"e",e:"1.000000",s:"1.000000",o:"2"},{f:"2",t:7.07,d:1.07,i:"e",e:"0.000000",s:"1.000000",o:"2"},{f:"3",t:7.21,d:0.23,i:"a",e:104,s:194,o:"2"}],f:30}},o:"1"},{x:1,p:"600px",c:"#0F2839",onSceneTimelineCompleteActions:[{type:1,transition:1,sceneSymbol:1}],v:{"20":{o:"content-box",h:"0",x:"visible",a:449,q:"100% 100%",b:251,j:"absolute",r:"inline",c:62,k:"div",z:"5",d:58,aY:"0",f:"360deg"},"19":{aU:8,G:"#FFFFFF",c:674,aV:8,r:"inline",d:46,e:"0.000000",s:"AppleGothic,sans-serif",t:24,Z:"break-word",aP:"pointer",w:"<div><span style=\"background-color: rgb(15, 40, 57); color: rgb(255, 255, 255); font-family: AppleGothic, sans-serif; text-align: center; \">Consider a medium size airline with 120 planes in their fleet.&nbsp;</span><br></div>",j:"absolute",x:"visible",aA:[],k:"div",y:"preserve",z:"1",aS:8,aT:8,a:165,F:"center",b:367},"54":{aU:8,G:"#FFFFFF",c:55,aV:8,r:"inline",d:15,e:"1.000000",s:"AppleGothic,sans-serif",t:16,Z:"break-word",aP:"pointer",w:"<div>SKIP &gt;</div>",j:"absolute",x:"visible",aA:[{type:4,javascriptOid:"36"}],k:"div",y:"preserve",z:"6",aS:8,aT:8,a:866,F:"right",b:743}},n:"fleet",T:{kTimelineDefaultIdentifier:{d:5.23,i:"kTimelineDefaultIdentifier",n:"Main Timeline",a:[{f:"2",t:0,d:0.28,i:"e",e:"0.000000",s:"0.000000",o:"19"},{f:"2",t:0,d:0.26,i:"a",e:479,s:449,o:"20"},{f:"2",t:0.26,d:1.08,i:"a",e:449,s:479,o:"20"},{f:"2",t:0.28,d:0.22,i:"a",e:135,s:165,o:"19"},{f:"2",t:0.28,d:1.08,i:"e",e:"1.000000",s:"0.000000",o:"19"},{f:"2",t:1.2,d:3.01,i:"a",e:135,s:135,o:"19"},{f:"2",t:2.06,d:2.08,i:"e",e:"1.000000",s:"1.000000",o:"19"},{f:"2",t:4.14,d:1.09,i:"e",e:"0.000000",s:"1.000000",o:"19"},{f:"2",t:4.21,d:1.02,i:"a",e:105,s:135,o:"19"}],f:30}},o:"21"},{x:2,p:"600px",c:"#0F2839",onSceneTimelineCompleteActions:[{type:1,transition:1,sceneSymbol:1}],v:{"14":{o:"content-box",h:"0",x:"visible",a:449,q:"100% 100%",b:251,j:"absolute",r:"inline",c:62,k:"div",z:"5",d:58,aY:"0",f:"360deg"},"55":{aU:8,G:"#FFFFFF",c:55,aV:8,r:"inline",d:15,e:"1.000000",s:"AppleGothic,sans-serif",t:16,Z:"break-word",aP:"pointer",w:"<div>SKIP &gt;</div>",j:"absolute",x:"visible",aA:[{type:4,javascriptOid:"36"}],k:"div",y:"preserve",z:"6",aS:8,aT:8,a:866,F:"right",b:743},"11":{aU:8,G:"#FFFFFF",c:665,aV:8,r:"inline",d:46,e:"0.000000",s:"AppleGothic,sans-serif",t:24,Z:"break-word",aP:"pointer",w:"<div><span style=\"color: rgb(255, 255, 255); font-family: AppleGothic, sans-serif; text-align: center; background-color: rgb(15, 40, 57); \">Saving just one minute of waiting time per flight can&nbsp;</span></div><div><span style=\"color: rgb(255, 255, 255); font-family: AppleGothic, sans-serif; text-align: center; background-color: rgb(15, 40, 57); \">save</span><span style=\"background-color: rgb(15, 40, 57); text-align: center; color: rgb(255, 255, 255); font-family: AppleGothic, sans-serif; \">&nbsp;$8.2M in fuel and $2.1M in crew costs&nbsp;annually.&nbsp;</span></div>",j:"absolute",x:"visible",aA:[],k:"div",y:"preserve",z:"1",aS:8,aT:8,a:169,F:"center",b:361}},n:"savings",T:{kTimelineDefaultIdentifier:{d:6.03,i:"kTimelineDefaultIdentifier",n:"Main Timeline",a:[{f:"2",t:0,d:0.28,i:"e",e:"0.000000",s:"0.000000",o:"11"},{f:"2",t:0.1,d:0.26,i:"a",e:480,s:449,o:"14"},{f:"2",t:0.28,d:1,i:"a",e:139,s:169,o:"11"},{f:"2",t:0.28,d:1.11,i:"e",e:"1.000000",s:"0.000000",o:"11"},{f:"2",t:1.06,d:1.18,i:"a",e:419,s:480,o:"14"},{f:"2",t:1.28,d:3.04,i:"a",e:139,s:139,o:"11"},{f:"2",t:2.09,d:2.13,i:"e",e:"1.000000",s:"1.000000",o:"11"},{f:"2",t:4.22,d:1.11,i:"e",e:"0.000000",s:"1.000000",o:"11"},{f:"2",t:5.02,d:0.28,i:"a",e:109,s:139,o:"11"}],f:30}},o:"13"},{x:3,p:"600px",c:"#0F2839",onSceneTimelineCompleteActions:[{type:4,javascriptOid:"36"}],v:{"31":{o:"content-box",h:"0",x:"visible",a:36,q:"100% 100%",b:380,j:"absolute",r:"inline",c:43,k:"div",z:"5",d:40,bF:"51",aY:"0",f:"360deg"},"42":{o:"content-box",h:"0",x:"visible",a:225,q:"100% 100%",b:40,j:"absolute",r:"inline",c:55,k:"div",z:"11",d:52,bF:"51",aY:"0",f:"360deg"},"32":{o:"content-box",h:"0",x:"visible",a:113,q:"100% 100%",b:259,j:"absolute",r:"inline",c:55,k:"div",z:"6",d:52,bF:"51",aY:"0",f:"360deg"},"37":{aU:8,G:"#FFFFFF",c:712,aV:8,r:"inline",d:46,e:"0.000000",s:"AppleGothic,sans-serif",t:24,Z:"break-word",aP:"pointer",w:"<div>The FlightQuest winning entries saved up to 2.5 minutes in</div><div>arrival prediction times using model data.</div>",j:"absolute",x:"visible",aA:[],k:"div",y:"preserve",z:"17",aS:8,aT:8,a:184,F:"center",b:359},"43":{o:"content-box",h:"0",x:"visible",a:58,q:"100% 100%",b:622,j:"absolute",r:"inline",c:55,k:"div",z:"12",d:52,bF:"51",aY:"0",f:"360deg"},"48":{o:"content-box",h:"0",x:"visible",a:107,q:"100% 100%",b:110,j:"absolute",r:"inline",c:43,k:"div",z:"17",d:40,bF:"51",aY:"0",f:"360deg"},"44":{o:"content-box",h:"0",x:"visible",a:163,q:"100% 100%",b:564,j:"absolute",r:"inline",c:62,k:"div",z:"13",d:58,bF:"51",aY:"0",f:"360deg"},"51":{k:"div",x:"visible",c:281,d:708,z:"7",e:"0.115494",a:-281,j:"absolute",b:16},"45":{o:"content-box",h:"0",x:"visible",a:66,q:"100% 100%",b:477,j:"absolute",r:"inline",c:62,k:"div",z:"14",d:58,bF:"51",aY:"0",f:"360deg"},"56":{aU:8,G:"#FFFFFF",c:55,aV:8,r:"inline",d:15,e:"1.000000",s:"AppleGothic,sans-serif",t:16,Z:"break-word",aP:"pointer",w:"<div>SKIP &gt;</div>",j:"absolute",x:"visible",aA:[{type:4,javascriptOid:"36"}],k:"div",y:"preserve",z:"19",aS:8,aT:8,a:866,F:"right",b:743},"29":{o:"content-box",h:"0",x:"visible",a:201,q:"100% 100%",b:188,j:"absolute",r:"inline",c:43,k:"div",z:"3",d:40,bF:"51",aY:"0",f:"360deg"},"35":{o:"content-box",h:"0",x:"visible",a:225,q:"100% 100%",b:451,j:"absolute",r:"inline",c:43,k:"div",z:"9",d:40,bF:"51",aY:"0",f:"360deg"},"46":{o:"content-box",h:"0",x:"visible",a:66,q:"100% 100%",b:16,j:"absolute",r:"inline",c:62,k:"div",z:"15",d:58,bF:"51",aY:"0",f:"360deg"},"39":{o:"content-box",h:"0",x:"visible",a:419,q:"100% 100%",b:252,j:"absolute",r:"inline",c:62,k:"div",z:"18",d:58,aY:"0",e:"1.000000",f:"360deg"}},n:"fleet Copy",T:{kTimelineDefaultIdentifier:{d:6.22,i:"kTimelineDefaultIdentifier",n:"Main Timeline",a:[{f:"2",t:0,d:0.17,i:"a",e:-281,s:-281,o:"51"},{f:"2",t:0.04,d:0.25,i:"a",e:449,s:419,o:"39"},{f:"2",t:0.04,d:0.26,i:"e",e:"1.000000",s:"0.115494",o:"51"},{f:"2",t:0.17,d:1.29,i:"a",e:-31,s:-281,o:"51"},{f:"2",t:0.26,d:0.29,i:"e",e:"1.000000",s:"0.000000",o:"37"},{f:"2",t:0.29,d:0.22,i:"a",e:419,s:449,o:"39"},{f:"2",t:1,d:3.1,i:"e",e:"1.000000",s:"1.000000",o:"51"},{f:"2",t:1.01,d:0.24,i:"a",e:134,s:184,o:"37"},{f:"2",t:1.21,d:2.09,i:"a",e:419,s:419,o:"39"},{f:"2",t:1.25,d:2.23,i:"a",e:134,s:134,o:"37"},{f:"2",t:1.25,d:2.12,i:"e",e:"1.000000",s:"1.000000",o:"37"},{f:"2",t:2.16,d:1.24,i:"a",e:-31,s:-31,o:"51"},{f:"2",t:4,d:2.02,i:"a",e:819,s:419,o:"39"},{f:"2",t:4.04,d:2,i:"e",e:"0.000000",s:"1.000000",o:"39"},{f:"2",t:4.07,d:1.05,i:"e",e:"0.000000",s:"1.000000",o:"37"},{f:"2",t:4.1,d:2.09,i:"e",e:"0.000000",s:"1.000000",o:"51"},{f:"2",t:4.1,d:0.22,i:"a",e:180,s:-31,o:"51"},{f:"2",t:4.18,d:0.2,i:"a",e:85,s:134,o:"37"},{f:"2",t:5.02,d:0.1,i:"a",e:388,s:180,o:"51"},{f:"2",t:5.12,d:1.1,i:"a",e:716,s:388,o:"51"}],f:30}},o:"26"}];
	
	var javascripts = [{name:"introComplete",source:"function(hypeDocument, element, event) {\tflightApp.introComplete();\n\t\n}",identifier:"36"}];
	
	var functions = {};
	var javascriptMapping = {};
	for(var i = 0; i < javascripts.length; i++) {
		try {
			javascriptMapping[javascripts[i].identifier] = javascripts[i].name;
			eval("functions." + javascripts[i].name + " = " + javascripts[i].source);
		} catch (e) {
			hypeDoc.log(e);
			functions[javascripts[i].name] = (function () {});
		}
	}
	
	hypeDoc.setAttributeTransformerMapping(attributeTransformerMapping);
	hypeDoc.setResources(resources);
	hypeDoc.setScenes(scenes);
	hypeDoc.setJavascriptMapping(javascriptMapping);
	hypeDoc.functions = functions;
	hypeDoc.setCurrentSceneIndex(0);
	hypeDoc.setMainContentContainerID(mainContainerID);
	hypeDoc.setResourcesFolderName(resourcesFolderName);
	hypeDoc.setShowHypeBuiltWatermark(0);
	hypeDoc.setShowLoadingPage(false);
	hypeDoc.setDrawSceneBackgrounds(true);
	hypeDoc.setGraphicsAcceleration(true);
	hypeDoc.setDocumentName(documentName);

	HYPE.documents[documentName] = hypeDoc.API;
	document.getElementById(mainContainerID).setAttribute("HYPE_documentName", documentName);

	hypeDoc.documentLoad(this.body);
}());

