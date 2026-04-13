var app = document.getElementById('app');
var materialsList = document.getElementById('materialsList');
var selectedInfo = document.getElementById('selectedInfo');
var recipeInfo = document.getElementById('recipeInfo');
var amountInput = document.getElementById('amountInput');
var submitBtn = document.getElementById('submitBtn');
var cancelBtn = document.getElementById('cancelBtn');
var closeBtn = document.getElementById('closeBtn');

var recipes = [];
var selectedIndex = -1;

function getResourceName() {
  if (typeof GetParentResourceName === 'function') {
    return GetParentResourceName();
  }
  return 'it_drugs';
}

function post(url, data) {
  if (!data) data = {};
  return fetch('https://' + getResourceName() + '/' + url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data)
  });
}

function closeUi() {
  app.style.display = 'none';
}

function openUi(payload) {
  recipes = payload.items || [];
  materialsList.innerHTML = '';
  selectedIndex = -1;

  for (var i = 0; i < recipes.length; i++) {
    (function(index) {
      var recipe = recipes[index];
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'material-btn';
      btn.textContent =
        '[' + recipe.slot + '] ' + recipe.label + ' x' + recipe.count +
        ' | ' + recipe.recipeLabel + ' -> ' + recipe.outputItem;
      btn.addEventListener('click', function() {
        selectMaterial(index);
      });
      materialsList.appendChild(btn);
    })(i);
  }

  amountInput.value = '3';
  if (recipes.length > 0) {
    selectMaterial(0);
  } else {
    selectedInfo.textContent = '使用できる素材がありません';
    recipeInfo.textContent = '';
  }
  updateRecipeInfo();
  app.style.display = 'flex';
}

function selectMaterial(index) {
  selectedIndex = index;
  var buttons = materialsList.getElementsByClassName('material-btn');
  for (var i = 0; i < buttons.length; i++) {
    if (i === index) {
      buttons[i].classList.add('active');
    } else {
      buttons[i].classList.remove('active');
    }
  }
  updateRecipeInfo();
}

function getSelectedRecipe() {
  if (selectedIndex < 0 || selectedIndex >= recipes.length) return null;
  return recipes[selectedIndex];
}

function updateRecipeInfo() {
  var recipe = getSelectedRecipe();
  if (!recipe) {
    selectedInfo.textContent = '素材を選択してください';
    recipeInfo.textContent = '';
    return;
  }
  selectedInfo.textContent =
    '[' + recipe.slot + '] ' + recipe.label + ' x' + recipe.count +
    ' / レシピ: ' + recipe.recipeLabel + ' / 生成: ' + recipe.outputItem + ' x' + recipe.outputCount;
  recipeInfo.textContent = '正しい配合: ' + recipe.inputPerBatch + ' の倍数で成功';
}

function submit() {
  var recipe = getSelectedRecipe();
  var inputAmount = Number(amountInput.value || 0);
  if (!recipe || isNaN(inputAmount) || inputAmount < 1) return;

  post('submitProcess', {
    slot: recipe.slot,
    itemName: recipe.itemName,
    recipeKey: recipe.recipeKey,
    inputAmount: inputAmount
  });
  closeUi();
}

function cancel() {
  post('cancelProcess');
  closeUi();
}

window.addEventListener('message', function(event) {
  var data = event.data;
  if (!data || !data.action) return;

  if (data.action === 'openProcessUi') {
    try {
      openUi(data);
    } catch (e) {
      app.style.display = 'flex';
    }
  }
});

submitBtn.addEventListener('click', submit);
cancelBtn.addEventListener('click', cancel);
closeBtn.addEventListener('click', cancel);

window.addEventListener('keydown', function(event) {
  if (event.key === 'Escape') cancel();
});

window.addEventListener('load', function() {
  post('uiReady');
});

