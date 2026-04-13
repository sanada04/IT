var Mainlocation = null
var MainspawnType = null

$(document).ready(function() {

    $(".container").hide();

    window.addEventListener('message', function(event) {
        var data = event.data;
        if (data.type === "ui") {
            if (data.status == true) {
                $(".container").fadeIn(250);
            } else {
                $(".container").fadeOut(250);
            }
        }

        if (data.action == "setupLocations") {
            setupNewLocations(data.locations, data.houses, data.Apartment, data.ApartmentNames, data.Access)
        }

        if (data.action == "setupFirstCharacterSpawn") {
            setupFirstCharacterSpawn(data.spawns)
        }

        if (data.action == "setupAppartements") {
            setupApps(data.locations)
        }

        if (data.action == "AddCoord") {
            $(".AddBlipForMap").html("")

            $(".AddCoord").fadeIn(250);
            $("#VecX").val(data.Coord.x);
            $("#VecY").val(data.Coord.y);
            $("#VecZ").val(data.Coord.z);
            $("#VecH").val(data.Coord.h);

            $("#BlipTop").val(50);
            $("#BlipLeft").val(50);
            $('.AddBlipForMap').append('<i style="top:'+50+'%; left:'+50+'%;" id="BlipSetting" class="fas fa-map-marker-alt location-pin IconClassStyle"></i>')
        }
    })
})

$("#BlipTop").keyup(function(){
    var Top = this.value
    $("#BlipSetting").css({"top":Top+"%"});
});

$("#BlipLeft").keyup(function(){
    var Left = this.value
    $("#BlipSetting").css({"left":Left+"%"});
});

var SelectLocForSpawn = null
var apartNames = null
var spawnLocationsTable = {}
var spawnAppsPositions = {}
var isFirstCharacterSpawnFlow = false

function hideSpawnActivePin() {
    $('#spawn-active-pin').addClass('hidden')
}

function showSpawnActivePin(top, left, buildingStyle) {
    var $p = $('#spawn-active-pin')
    $p.removeClass('hidden IconClassStyle IconClassStyle2 fa-map-marker-alt fa-building')
    if (buildingStyle) {
        $p.addClass('fa-building IconClassStyle2')
    } else {
        $p.addClass('fa-map-marker-alt IconClassStyle')
    }
    $p.css({ top: top + '%', left: left + '%' })
}

function refreshSpawnPin() {
    if (!SelectLocForSpawn) {
        hideSpawnActivePin()
        return
    }
    if (SelectLocForSpawn.tagName && SelectLocForSpawn.tagName.toLowerCase() === 'i') {
        hideSpawnActivePin()
        return
    }
    var type = MainspawnType
    var loc = Mainlocation
    if (type === 'current') {
        hideSpawnActivePin()
        return
    }
    if (type === 'normal') {
        var e = spawnLocationsTable[loc]
        if (e && e.pos && e.pos.top != null && e.pos.left != null) {
            showSpawnActivePin(e.pos.top, e.pos.left, false)
        } else {
            hideSpawnActivePin()
        }
        return
    }
    if (type === 'appartment2' && window.spawnApartmentPos && window.spawnApartmentPos.top != null) {
        showSpawnActivePin(window.spawnApartmentPos.top, window.spawnApartmentPos.left, true)
        return
    }
    if (type === 'appartment') {
        var ap = spawnAppsPositions[loc]
        if (ap && ap.top != null && ap.left != null) {
            showSpawnActivePin(ap.top, ap.left, true)
        } else {
            hideSpawnActivePin()
        }
        return
    }
    hideSpawnActivePin()
}

$(document).on('click', '.spawn-picker-btn', function(evt){
    evt.preventDefault();
    var location = $(this).data('location');
    var type = $(this).data('type');
    var label = $(this).data('label');
    if (type == "appartment2") {
        apartNames = $(this).data('apartname')
    }
    $(".TextFoJSCode").html("スポーン位置を選択")
    if (type !== "lab") {

        $.post('https://qb-spawn/setCam', JSON.stringify({
            posname: location,
            type: type,
        }));

        if(SelectLocForSpawn == null){
            SelectLocForSpawn = this
            Mainlocation = location
            MainspawnType = type
            $(this).addClass('selected');
            if(MainspawnType == "appartment"){
                $(".TextFoJSCode").html("アパート: "+label)
            }else{
                $(".TextFoJSCode").html(label)
            }
        }else if(SelectLocForSpawn == this){
            $(this).removeClass("selected");
            if(MainspawnType == "appartment"){
                $(".TextFoJSCode").html("アパートを選択")
            }else{
                $(".TextFoJSCode").html("スポーン位置を選択")
            }
            SelectLocForSpawn = null
            Mainlocation = null
            MainspawnType = null
            
        }else{
            $(SelectLocForSpawn).removeClass("selected");
            $(this).addClass('selected');
            Mainlocation = location
            MainspawnType = type
            SelectLocForSpawn = this
            if(MainspawnType == "appartment"){
                $(".TextFoJSCode").html("アパート: "+label)
            }else{
                $(".TextFoJSCode").html(label)
            }
        }
        refreshSpawnPin()
    }
});

$(document).on('click', '.GreenBTN', function(evt){
    evt.preventDefault();

    if (Mainlocation !== null){
        $(".container").addClass("hideContainer").fadeOut("9000");
        setTimeout(function(){
            $(".hideContainer").removeClass("hideContainer");
        }, 900);

        $(SelectLocForSpawn).removeClass("selected");
        SelectLocForSpawn = null
        hideSpawnActivePin()

        if (MainspawnType == "apartment1") {
            $.post('https://qb-spawn/spawnplayerappartment1', JSON.stringify({
                spawnloc: Mainlocation,
                apartName: apartNames,
            }));
        } else if(MainspawnType !== "appartment"){
            var spawnPayload = {
                spawnloc: Mainlocation,
                typeLoc: MainspawnType
            }
            if (isFirstCharacterSpawnFlow) {
                spawnPayload.firstCharacterSpawn = true
            }
            $.post('https://qb-spawn/spawnplayer', JSON.stringify(spawnPayload));
        }else {
            $.post('https://qb-spawn/chooseAppa', JSON.stringify({
                appType: Mainlocation,
            }));
        } 
    } else {
        console.log('Error: Not location selected')
    }

});

$(document).on('click', '.CloseBTN', function(evt){
    evt.preventDefault();
    CloseAddCoord()
});

function setupNewLocations(locations, myHouses, Apartment, ApartmentName, Access) {
    isFirstCharacterSpawnFlow = false
    var parent = $('.spawn-locations-new')
    spawnLocationsTable = locations || {}
    spawnAppsPositions = {}
    window.spawnApartmentPos = null
    $(parent).html('<i id="spawn-active-pin" class="fas fa-map-marker-alt spawn-active-pin hidden IconClassStyle" aria-hidden="true"></i>');

    $(".spawn-action-bar").fadeIn(1);
    $(".QuickSpawnBTN").show();
    $(".GreenBTN").show();
    $(".TextFoJSCode").html("スポーン位置を選択")
    Mainlocation = null
    MainspawnType = null
    hideSpawnActivePin()
    if(SelectLocForSpawn !== null){
        $(SelectLocForSpawn).removeClass("selected");
        SelectLocForSpawn = null
    }

    if(Access.lastLoc == false){
        $(".LastBTN").fadeOut(1);
    } else {
        $(".LastBTN").fadeIn(1);
    }

    if(Access.apartments == true && Apartment && Apartment.pos !== undefined){
        window.spawnApartmentPos = { top: Apartment.pos.top, left: Apartment.pos.left }
    }
}

function setupFirstCharacterSpawn(spawns) {
    isFirstCharacterSpawnFlow = true
    var parent = $('.spawn-locations-new')
    spawnLocationsTable = spawns || {}
    spawnAppsPositions = {}
    window.spawnApartmentPos = null
    $(parent).html('<i id="spawn-active-pin" class="fas fa-map-marker-alt spawn-active-pin hidden IconClassStyle" aria-hidden="true"></i>');

    $(".spawn-action-bar").fadeIn(1);
    $(".QuickSpawnBTN[data-location='lspd']").hide();
    $(".QuickSpawnBTN[data-location='cityhall']").show();
    $(".LastBTN").hide();
    $(".GreenBTN").show();

    $(".TextFoJSCode").html("スポーン位置を選択")
    Mainlocation = null
    MainspawnType = null
    hideSpawnActivePin()
    if (SelectLocForSpawn !== null) {
        $(SelectLocForSpawn).removeClass("selected");
        SelectLocForSpawn = null
    }
}

function setupApps(apps) {
    isFirstCharacterSpawnFlow = false
    var parent = $('.spawn-locations-new')
    spawnAppsPositions = {}
    $(parent).html('<i id="spawn-active-pin" class="fas fa-map-marker-alt spawn-active-pin hidden IconClassStyle" aria-hidden="true"></i>');

    $(".spawn-action-bar").fadeOut(1);
    $(".TextFoJSCode").html('SELECT <i style="color: black;" class="fas fa-check"></i>')

    $(".TextFoJSCode").html("アパートを選択")
    Mainlocation = null
    MainspawnType = null
    if(SelectLocForSpawn !== null){
        $(SelectLocForSpawn).removeClass("selected");
        SelectLocForSpawn = null
    }

    $.each(apps, function(index, app){
        if(app.pos !== undefined){
            spawnAppsPositions[app.name] = { top: app.pos.top, left: app.pos.left }
            $(parent).append('<i style="top:'+app.pos.top+'%; left:'+app.pos.left+'%;" data-location="'+app.name+'" data-type="appartment" data-label="'+app.label+'" class="fas fa-building IconClassStyle2 spawn-picker-btn"></i>')
        }
    });
}

function CloseAddCoord() {
    $.post('https://qb-spawn/CloseAddCoord', JSON.stringify({}));
    $(".AddCoord").fadeOut(250);
}

const copyToClipboard = str => {
    const el = document.createElement('textarea');
    el.value = str;
    document.body.appendChild(el);
    el.select();
    document.execCommand('copy');
    document.body.removeChild(el);
};

$(document).on('click', '.ApartBTN', function(e){
    e.preventDefault();
    let source = '["'+$("#VecName").val()+'"] = {'+
                    'name = "'+$("#VecName").val()+'",'+
                    'label = "'+$("#VecLabel").val()+'",'+
                    'coords = {'+
                        'enter = vector4('+$("#VecX").val()+', '+$("#VecY").val()+', '+$("#VecZ").val()+', '+$("#VecH").val()+'),'+
                    '},'+
                    'pos = {top = '+$("#BlipTop").val()+', left = '+$("#BlipLeft").val()+'},'+
                '},';
    copyToClipboard(source)
    CloseAddCoord()
});

$(document).on('click', '.SpawnBTN', function(e){
    e.preventDefault();
    let source = '["'+$("#VecName").val()+'"] = {'+
                    'coords = vector4('+$("#VecX").val()+', '+$("#VecY").val()+', '+$("#VecZ").val()+', '+$("#VecH").val()+'),'+
                    'location = "'+$("#VecName").val()+'",'+
                    'label = "'+$("#VecLabel").val()+'",'+
                    'pos = {top = '+$("#BlipTop").val()+', left = '+$("#BlipLeft").val()+'},'+
                '},';
    copyToClipboard(source)
    CloseAddCoord()
});
