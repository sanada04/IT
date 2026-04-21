var jsTranslate = [];
var wikiPage = [];
var marketPage = [];
var salesPage = [];
var tasksPage = [];
var levelPages = [];
var firstOpen = true;
var profilePhoto = "";
var maxLevel = 30;
var level = 1,
    xp = 0,
    neededEXP = 1000;

window.addEventListener("message", (event) => {
    if (event.data.type === "openUi") {
        if (event.data.avatarUrl && event.data.avatarUrl.length > 8) {
            profilePhoto = event.data.avatarUrl;
            $(".profilePhotoAK4Y").attr("src", profilePhoto);
            firstOpen = false;
        } else if (firstOpen && event.data.steamid && event.data.steamid !== "null") {
            firstOpen = false;
            var xhr = new XMLHttpRequest();
            xhr.responseType = "text";
            xhr.open("GET", event.data.steamid, true);
            xhr.send();
            xhr.onreadystatechange = processRequest;
            function processRequest(e) {
                if (xhr.readyState == 4 && xhr.status == 200) {
                    var string = xhr.responseText.toString();
                    var array = string.split("avatarfull");
                    var array2 = array[1].toString().split('"');
                    profilePhoto = array2[2].toString();
                    $(".profilePhotoAK4Y").attr("src", profilePhoto);
                }
            }
        } else {
            $(".profilePhotoAK4Y").attr("src", profilePhoto);
        }
        jsTranslate = event.data.jsTranslate;

        $(".generalDescription").html(jsTranslate.generalTitleDescription);

        $("#wikiButton").html(jsTranslate.wiki);
        $("#marketButton").html(jsTranslate.market);
        $("#salesButton").html(jsTranslate.sales);
        $("#tasksButton").html(jsTranslate.tasks);
        $("#lvlBuyButton").html(jsTranslate.lvlBuy);

        $(".helloText").html(jsTranslate.hello);

        $(".bigLevelText").html(jsTranslate.level);
        $(".expText").html(jsTranslate.exp);

        $(".BuyingFirst").html(jsTranslate.howAbout);
        $(".spawnBuyingSecond").html(jsTranslate.buyingALevel);

        $(".levelBuyButton").html(jsTranslate.levelBuy);

        maxLevel = event.data.maxLevel;
        neededEXP = neededEXP;
        $(".firstName").html(event.data.firstname);
        $(".lastName").html(event.data.lastname);
        giveExp(parseInt(event.data.currentXP));
        levelPages = event.data.levelPackages;
        wikiPage = event.data.wikiPage;
        marketPage = event.data.marketPage;
        salesPage = event.data.salesPage;
        tasksPage = event.data.tasksPage;
        setTasks(tasksPage, event.data.playerTasks, event.data.taskResetTimes);
        $(".generalSection").fadeIn(200);
        $(".catButton:first-child").click();
    } else if (event.data.type === "addEXP") {
        giveJustExp(parseInt(event.data.exp));
    } else if (event.data.type === "setJsTranslate") {
        jsTranslate = event.data.jsTranslate;
    } else if (event.data.type === "openProgress") {
        var animal = event.data.animal;
        var progressTime = event.data.time;
        var image = "./images/animalDeer.png";
        var name = jsTranslate.deer;
        var description = jsTranslate.deerDescriptionProgressBar;
        if (animal == "chicken") {
            image = "./images/chickenProgress.png";
            name = jsTranslate.chicken;
            description = jsTranslate.chickenDescriptionProgressBar;
        }
        if (animal == "pig") {
            image = "./images/pigProgress.png";
            name = jsTranslate.pig;
            description = jsTranslate.pigDescriptionProgressBar;
        }
        $(".progressAnimalName").html(name);
        $(".progressBarDescription").html(description);
        $(".progressBarImage").attr("src", image);
        $(".progressMain").fadeIn(200);

        $("#myProgress")
            .stop()
            .animate(
                {
                    width: "100%",
                },
                {
                    duration: parseInt(progressTime),
                    complete: function () {
                        $(".progressMain").fadeOut(200);
                        setTimeout(() => {}, 200);
                        $("#myProgress").css("width", 0);
                    },
                }
            );
    }
});

function setTasks(data, userDetails, times) {
    $(".tasksSection").empty();
    for (let i = 0; i < data.length; i++) {
        const element = data[i];
        var userDet = JSON.parse(userDetails);
        if (typeof userDet[i] !== "undefined") {
            var getRewardText = ``;
            if (!userDet[i].taken && userDet[i].hasCount >= element.requiredCount) {
                $.post("https://ak4y-advancedHunting/taskDone", JSON.stringify({ taskId: element.taskId }));
                $(".receivedItemNameText").html("- $" + element.rewardPrice);
                $(".taskCompleteNotify").fadeIn(200);
                setTimeout(() => {
                    $(".taskCompleteNotify").fadeOut(200);
                }, 1000);
            }
            if (userDet[i].hasCount >= element.requiredCount) {
                getRewardText = `<div class="taskCompletedText">${jsTranslate.collected}</div>`;
            }
            var deneme = `
                <div class="taskItem">
                    ${getRewardText}
                    <div class="taskItemTopArea">
                        <div class="taskTopLeftWrapper">
                            <div class="taskTitle">${element.taskTitle}</div>
                        </div>
                        <div class="taskTopRightWrapper">
                            <i id="clockIcon" class="fa-solid fa-clock"></i>
                            <div class="taskRemainingTime">${times}</div>
                        </div>
                    </div>
                    <div class="taskItemDescription">
                        ${element.taskDescription}
                    </div>
                    <div class="taskInfoSection">
                        <div class="taskItemRewardArea">
                            <i id="giftIcon" class="fa-solid fa-gift"></i>
                            <div class="rewardTextArea">
                                <div class="rewardText">${jsTranslate.reward}</div>
                                <div class="rewardItemName">$${element.rewardPrice}</div>
                            </div>
                        </div>
                        <div class="taskCountArea">
                            <div class="currentTaskCount">${userDet[i].hasCount}</div>
                            <div class="requiredTaskCount">/${element.requiredCount}</div>
                        </div>
                    </div>
                    <div class="taskItemFillArea">
                        <div class="taskItemFill" style="width:${(userDet[i].hasCount / element.requiredCount) * 100}%"></div>
                    </div>
                </div>
            `;
            $(".tasksSection").append(deneme);
        }
    }
}

$(document).on("keydown", function () {
    switch (event.keyCode) {
        case 27: // ESC
            closeMenu();
            break;
    }
});

function updatecounters() {
    if (xp >= neededEXP) {
        level += Math.floor(xp / neededEXP);
        xp = xp % neededEXP;
    }
    if (level > maxLevel) {
        level = maxLevel;
    }
    setTimeout(() => {
        $(".expFill").css("width", (xp / neededEXP) * 100 + "%");
        $(".myCurrentExperience").html(xp);
        $(".myCurrentXPCount").html(xp);
        $(".requiredExperience").html("/ " + neededEXP);
        $(".reqExpCount").html(neededEXP);
        $(".bigCurrentMyLevel").html(level);
    }, 100);
}

function giveExp(number) {
    level = 1;
    xp = 0;
    xp += number;
    updatecounters();
}

function giveJustExp(number) {
    xp += number;
    updatecounters();
}

function closeMenu() {
    $.post("https://ak4y-advancedHunting/closeMenu", JSON.stringify());
    $(".generalSection").hide();
    $(".purchaseNotify").hide();
    $(".purchaseSale").hide();
    $(".taskCompleteNotify").hide();
    $(".completeBuySection").hide();
}

function rightWrapperReset() {
    $(".marketSection").hide();
    $(".salesSection").hide();
    $(".tasksSection").hide();
    $(".levelBuySection").hide();
    $(".wikiSection").hide();
}

$(document).on("click", ".catButton", function () {
    $(".catButton.selected").css("box-shadow", "0px 0px 55px 10px rgba(54, 255, 122, 0.0)");
    var current = document.getElementsByClassName("catButton selected");
    if (current.length > 0) {
        current[0].className = current[0].className.replace("catButton selected", "catButton");
    }
    this.className += " selected";
});

$(document).on("click", "#wikiButton", function () {
    $(".wikiSection").empty();
    rightWrapperReset();
    $(".catButton.selected").css("box-shadow", "0px 0px 55px 10px rgba(180, 121, 255, 0.22)");
    wikiPage.forEach((element) => {
        var starText = ``;
        var weaponsName = ``;
        var animals = ``;
        for (let index = 0; index < 5; index++) {
            if (index < element.starCount) {
                starText += `<i id="starIcon" class="fa-solid fa-star"></i>`;
            } else {
                starText += `<i id="starIcon" class="fa-regular fa-star"></i>`;
            }
        }
        element.allowedWeapons.forEach((index, element) => {
            weaponsName += `<div class="wikiWeaponName">${index}</div>`;
        });
        element.animals.forEach((index, element) => {
            animals += `<div class="wikiAnimalsName">${index}</div>`;
        });
        $(".wikiSection").append(`
            <div class="wikiItem">
                <div class="wikiItemArea">
                    <div class="wikiStarSection">
                        ${starText}
                    </div>
                    <div class="wikiRegionName">${element.areaTitle}</div>
                    <div class="wikiRegionAnimalsType">${element.areaMiniTitle}</div>
                    <div class="wikiDescription">
                        ${element.areaDescription}
                    </div>
                    <div class="wikiWeaponTitle">${jsTranslate.weapon}</div>
                    <div class="wikiRectangle"></div>
                    <div class="wikiWeaponArea">
                        ${weaponsName}
                    </div>
                    <div class="wikiAnimalsTitle">${jsTranslate.animals}</div>
                    <div class="wikiRectangle"></div>
                    <div class="wikiAnimalsArea">
                        ${animals}
                    </div>
                    <div class="wikiSetGps" data-wayPoint='${JSON.stringify(element.areaCoords)}'>${jsTranslate.setGps}</div>
                </div>
                <div class="wikiItemImgBgArea">
                    <img src=${element.areaImage} alt="" />
                </div>
            </div>
        `);
    });
    $(".wikiSection").css("display", "flex");
});

$(document).on("click", ".wikiSetGps", function () {
    var selectedDiv = this;
    var waypointCoord = $(selectedDiv).attr("data-wayPoint");
    $.post(
        "https://ak4y-advancedHunting/setWaypoint",
        JSON.stringify({
            waypointCoord: waypointCoord,
        }),
        function (data) {}
    );
});

$(document).on("click", "#marketButton", function () {
    $(".marketSection").empty();
    rightWrapperReset();
    $(".catButton.selected").css("box-shadow", "0px 0px 55px 10px rgba(54, 255, 122, 0.22)");
    marketPage.forEach((element) => {
        $(".marketSection").append(`
            <div class="marketItem">
                <div class="marketItemName">${element.itemLabel}</div>
                <div class="marketItemImgArea">
                    <img src=${element.itemImage} alt="" />
                </div>
                <div class="marketItemCount">X${element.itemCount}</div>
                <div class="marketItemBottomSection">
                    <div class="marketItemMoneyArea">
                        <span class="marketItemDollarIcon">$</span>
                        <span class="marketItemPrice">${element.itemPrice}</span>
                    </div>
                    <div class="marketItemBuyButton" data-itemId='${element.uniqueId}'>${jsTranslate.buy}</div>
                </div>
            </div>
        `);
    });
    $(".marketSection").css("display", "flex");
});

$(document).on("click", ".marketItemBuyButton", function () {
    var selectedDiv = this;
    var itemId = $(selectedDiv).attr("data-itemId");
    $.post(
        "https://ak4y-advancedHunting/buyItem",
        JSON.stringify({
            itemId: itemId,
        }),
        function (data) {
            if (data) {
                $(".completeBuySection").fadeIn(200);
                setTimeout(() => {
                    $(".completeBuySection").fadeOut(200);
                }, 700);
            } else {
            }
        }
    );
});

$(document).on("click", "#salesButton", function () {
    $(".salesSection").empty();
    rightWrapperReset();
    $(".catButton.selected").css("box-shadow", "0px 0px 55px 10px rgba(255, 117, 117, 0.22)");
    salesPage.forEach((element) => {
        var starText = ``;
        for (let index = 0; index < element.itemStar; index++) {
            if (index < 6) {
                starText += `<i class="fa-solid fa-star"></i>`;
            }
        }
        $(".salesSection").append(`
            <div class="salesItem">
                <div class="salesItemName">${element.itemLabel}</div>
                <div class="salesItemImgArea">
                    <img src=${element.itemImage} alt="" />
                </div>
                <div class="salesItemStarSection">
                    ${starText}
                </div>
                <div class="salesItemInfoArea">
                    <div class="salesInfoLeftWrapper">
                        <div class="salesItemCount">X1</div>
                    </div>
                    <div class="salesInfoRightWrapper">
                        <div class="salesItemPrice">
                            <span class="salesItemDollarIcon">$</span>
                            <span class="salesItemRealPrice">${element.itemPrice}</span>
                        </div>
                    </div>
                </div>
                <div class="salesItemBottomSection">
                    <input
                        id="buyCount-${element.uniqueId}"
                        type="text"
                        class="amountInput"
                        value="amount..."
                        onblur="if(this.value == '') { this.value='amount...'}"
                        onfocus="if (this.value == 'amount...') {this.value=''}"
                    />
                    <div class="salesItemBuyButton" data-sellUnique='${element.uniqueId}'>${jsTranslate.sell}</div>
                </div>
            </div>
        `);
    });
    $(".salesSection").css("display", "flex");
});

$(document).on("click", ".salesItemBuyButton", function () {
    let itemId = $(this).attr("data-sellUnique");
    let itemCount = $("#buyCount-" + itemId).val();
    if (itemCount > 0) {
        $.post(
            "https://ak4y-advancedHunting/sellItem",
            JSON.stringify({
                itemId: itemId,
                itemCount: itemCount,
            }),
            function (data) {
                if (data) {
                    $(".purchaseSale").fadeIn(200);
                    setTimeout(() => {
                        $(".purchaseSale").fadeOut(200);
                    }, 1300);
                }
            }
        );
    }
});

$(document).on("click", "#tasksButton", function () {
    rightWrapperReset();
    $(".catButton.selected").css("box-shadow", "0px 0px 55px 10px rgba(138, 185, 255, 0.22)");
    $(".tasksSection").css("display", "flex");
});

$(document).on("click", ".levelBuyButton", function () {
    $(".catButton.selected").css("box-shadow", "0px 0px 55px 10px rgba(54, 255, 122, 0.0)");
    var current = document.getElementsByClassName("catButton selected");
    if (current.length > 0) {
        current[0].className = current[0].className.replace("catButton selected", "catButton");
    }
    document.getElementById("lvlBuyButton").className = "catButton selected";
    $(".levelPackageItemArea").empty();
    rightWrapperReset();
    $(".catButton.selected").css("box-shadow", "0px 0px 55px 10px rgba(254, 193, 74, 0.22)");
    levelPages.forEach((element) => {
        $(".levelPackageItemArea").append(`
            <div class="levelPackage">
                <div class="levelPackageNameArea">
                    <div class="itemLevelText">${jsTranslate.level}</div>
                    <div class="itemLevelPackageTag">${jsTranslate.up} #${element.packageId}</div>
                </div>
                <div class="levelPackageMiddleSection">
                    <i id="bigUpIcon" class="fa-solid fa-angles-up"></i>
                    <div class="levelSectionUpInfoArea">
                        <div class="itemUpLevelCount">+${element.upLevel}</div>
                        <div class="itemMiddleLevelText">${jsTranslate.level}</div>
                        <div class="itemMiddleUPText">${jsTranslate.up}</div>
                    </div>
                    <i id="bigUpIcon" class="fa-solid fa-angles-up"></i>
                </div>
                <div class="levelItemBuyButton" data-directLink='${element.directLink}'>
                    <span class="levelItemRealPrice">$${element.realPrice}</span>
                    <span class="levelItemBuyText" >${jsTranslate.buy}</span>
                </div>
            </div>
        `);
    });
    $(".levelBuySection").css("display", "block");
});

$(document).on("click", "#lvlBuyButton", function () {
    $(".levelPackageItemArea").empty();
    rightWrapperReset();
    $(".catButton.selected").css("box-shadow", "0px 0px 55px 10px rgba(254, 193, 74, 0.22)");
    levelPages.forEach((element) => {
        $(".levelPackageItemArea").append(`
            <div class="levelPackage">
                <div class="levelPackageNameArea">
                    <div class="itemLevelText">${jsTranslate.level}</div>
                    <div class="itemLevelPackageTag">${jsTranslate.up} #${element.packageId}</div>
                </div>
                <div class="levelPackageMiddleSection">
                    <i id="bigUpIcon" class="fa-solid fa-angles-up"></i>
                    <div class="levelSectionUpInfoArea">
                        <div class="itemUpLevelCount">+${element.upLevel}</div>
                        <div class="itemMiddleLevelText">${jsTranslate.level}</div>
                        <div class="itemMiddleUPText">${jsTranslate.up}</div>
                    </div>
                    <i id="bigUpIcon" class="fa-solid fa-angles-up"></i>
                </div>
                <div class="levelItemBuyButton" data-directLink='${element.directLink}'>
                    <span class="levelItemRealPrice">$${element.realPrice}</span>
                    <span class="levelItemBuyText" >${jsTranslate.buy}</span>
                </div>
            </div>
        `);
    });
    $(".levelBuySection").css("display", "block");
});

$(document).on("click", ".levelItemBuyButton", function () {
    var directLink = $(this).attr("data-directLink");
    window.invokeNative("openUrl", directLink);
});

$(document).on("click", ".redeemAcceptButton", function () {
    var codeInputValue = $(".redeemInput").val();
    if (codeInputValue != "amount..." && codeInputValue.length > 0) {
        $.post(
            "https://ak4y-advancedHunting/sendInput",
            JSON.stringify({
                input: codeInputValue,
            }),
            function (data) {
                if (data) {
                    giveJustExp(data);
                }
            }
        );
    }
});
