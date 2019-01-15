$(document).ready(function() {
    //    const url="http://localhost:4000/guess"
    $("#submitGuess").click(submitGuess);
});

function submitGuess() {
    var guessText = $("#guessText").val();
    $.post(
        "guess",
        JSON.stringify({ guessText: guessText }),
        function(data,status){
            var result = data.result;
            if (result == "Invalid") {
                alert("Invalid guess: \"" + guessText + "\"");
            } else if (result == "TooLow") {
                $("#responseText").text("Too low!");
            } else if (result == "TooHigh") {
                $("#responseText").text("Too high!");
            } else if (result == "Correct") {
                $("#responseText").text("You got it! Now guess again!");
            }
        });
}
