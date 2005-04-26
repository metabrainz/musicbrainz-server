function SwapARLinks(theBtn) {
	var theForm = theBtn.form;
	if (theForm == null || theForm.link0 == null || theForm.link1) {
		var leftTD = document.getElementById("arlinkswap-link0-td");
		var rightTD = document.getElementById("arlinkswap-link1-td");
		var leftVAL = theForm.link0.value;
		var rightVAL = theForm.link1.value;
		if (leftTD != null && rightTD != null &&
			leftVAL != "" && rightVAL != "") {
			var tmp = leftTD.innerHTML;
			leftTD.innerHTML = rightTD.innerHTML;
			rightTD.innerHTML = tmp;
			tmp = theForm.link0.value;
			theForm.link0.value = theForm.link1.value
			theForm.link1.value = tmp;
		}
	}
}
document.getElementById("swap-clientside").style.display = "block";
document.getElementById("swap-serverside").style.display = "none";
