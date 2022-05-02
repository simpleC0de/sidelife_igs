$(function() {

    function display(bool, id, account, fuel, fuelcost, buyprice, soldfuel){
        if(bool) {
            initHtml(id, account, fuel, fuelcost, buyprice, soldfuel);
            $("#container").show();
            return;
        } else {
            $("#container").hide();
            return;
        }
    }
    display(false);

    window.addEventListener("message", function(event) {
        var item =  event.data;

        if(item.type === "ui") {
            if(item.status) {
                display(true, item.igsid, item.igsaccount, item.igsfuel, item.igsfuelcost, item.igsbuyprice, item.igssoldfuel)
                return;
            }else {
                display(false)
                return;
            }
        }

    })


    document.onkeyup = function(data) {
        if(data.which == 27) {
            $.post("http://sidelife_igs/varChange", JSON.stringify({cmd: "exit"}))
            return;
        }
    }

    //onsubmit press

    $("#submit").click(function(){
        // to get the value inside of a field do: 
        /*
        $("#lname").val()   ||| Remember checks to see if everything is okay with the value, dont do this on lua
        */

        let newFuelcost = $("#inpFuelcost").val()
        let newBuyprice = $("#inpBuyprice").val()

        let parsedFuel = parseInt(newFuelcost)
        let parsedBuyPrice = parseInt(newBuyprice)

        if(isStringNumber(newFuelcost)) {
            $.post("http://sidelife_igs/varChange", JSON.stringify({cmd: "fuelcost", value: parsedFuel}))
            //updateHtml("fuelcost", newFuelcost)
        }
        if(isStringNumber(newBuyprice)) {
            $.post("http://sidelife_igs/varChange", JSON.stringify({cmd: "buyprice", value: parsedBuyPrice}))
            //updateHtml("buyprice", newBuyprice)
        }
        $.post("http://sidelife_igs/varChange", JSON.stringify({cmd: "update"}))
        return;
    })

    $("#withdraw").click(function(){

        let withdrawal = $("#inpamount").val()
        let parsed = parseInt(withdrawal)
        if(isStringNumber(withdrawal)) {

            $.post("http://sidelife_igs/varChange", JSON.stringify({cmd: "withdraw", value: parsed}))
            $.post("http://sidelife_igs/varChange", JSON.stringify({cmd: "update"}))
            return;
        }


    })

    $("#deposit").click(function(){

        let withdrawal = $("#inpamount").val()
        let parsed = parseInt(withdrawal)
        if(isStringNumber(withdrawal)) {

            $.post("http://sidelife_igs/varChange", JSON.stringify({cmd: "deposit", value: parsed}))
            $.post("http://sidelife_igs/varChange", JSON.stringify({cmd: "update"}))
            return;
        }


    })


    $("#exit").click(function(){
        $.post("http://sidelife_igs/varChange", JSON.stringify({cmd: "exit"}))
    })

})

function initHtml(id, account, fuel, fuelcost, buyprice, soldfuel){
    //Used to declare variables and change the text corresponding to the users gas station
    $.post("http://sidelife_igs/varChange", JSON.stringify({cmd: "log", text: "Inithtml"}));

    document.getElementById("igs:id").innerHTML = "" + id;
    document.getElementById("igs:account").innerHTML = "$" + account;
    document.getElementById("igs:fuel").innerHTML = "" + fuel;
    document.getElementById("igs:fuelcost").innerHTML = "$" + fuelcost;
    document.getElementById("igs:buyprice").innerHTML = "$" + buyprice;
    document.getElementById("igs:soldfuel").innerHTML = "" + soldfuel;
}

function updateHtml(htmlValue, replaceValue){
    document.hide();
    switch (htmlValue) {
        case "id":
            
        break;

        case "account":

        break;

        case "fuel":

        break;

        case "fuelcost":
            document.getElementById("igs:fuelcost").innerHTML = "Benzinpreis: $" + replaceValue;
        break;

        case "buyprice":
            document.getElementById("igs:buyprice").innerHTML = "Einkaufspreis: $" + replaceValue;
        break;

        case "soldfuel":

        break;

        default:
            break;
    }

    document.show();
}

function isStringNumber(value){

    var numberRegex = /^[+-]?\d+(\.\d+)?([eE][+-]?\d+)?$/;
    if(numberRegex.test(value)) {
        return true;
    }
    return false;    

}