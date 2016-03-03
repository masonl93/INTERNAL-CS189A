function getLocation() {
    var x = document.getElementById("geolocation");
    if (navigator.geolocation) {
        navigator.geolocation.watchPosition(showPosition);
    } else {
        x.innerHTML = "Geolocation is not supported by this browser.";}
}
function showPosition(position) {
    var x = document.getElementById("geolocation");
    //x.innerHTML="Latitude: " + position.coords.latitude +
        //"<br>Longitude: " + position.coords.longitude;
    $.ajax({
        url: "/users/save_user_location",
        type: "POST",
        data: {lat: position.coords.latitude, long: position.coords.longitude}
    });
}
$(document).ready(function(){
  console.log(window.location.pathname)
   if (window.location.pathname === "/findMatch"
   || window.location.pathname === "/edit"){
     getLocation();
 }
});
//localstorage.getItem("isLoggedIn")
