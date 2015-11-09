/**
 * Created by Mason on 11/6/15.
 */

var x = document.getElementById("demo");
function getLocation() {
    if (navigator.geolocation) {
        navigator.geolocation.watchPosition(showPosition);
    } else {
        x.innerHTML = "Geolocation is not supported by this browser.";}
}
function showPosition(position) {
    x.innerHTML="Latitude: " + position.coords.latitude +
        "<br>Longitude: " + position.coords.longitude;
    $.ajax({
        url: "users/edit",
        type: "POST",
        data: {lat: position.coords.latitude, long: position.coords.longitude}
    });
}