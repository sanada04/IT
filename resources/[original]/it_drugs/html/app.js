var app = document.getElementById('app');
var materialGrid = document.getElementById('materialGrid');
var selectedList = document.getElementById('selectedList');
var selectedInfo = document.getElementById('selectedInfo');
var recipeInfo = document.getElementById('recipeInfo');
var submitBtn = document.getElementById('submitBtn');
var cancelBtn = document.getElementById('cancelBtn');
var closeBtn = document.getElementById('closeBtn');

var materials = [];
var selectedInputs = {};

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

function getItemImage(itemName, explicitImage) {
  var fileName = explicitImage || (itemName + '.png');
  return 'nui://ox_inventory/web/images/' + fileName;
}

function setImageWithFallback(img, itemName, explicitImage) {
  var triedFallback = false;
  img.src = getItemImage(itemName, explicitImage);
  img.onerror = function() {
    if (!triedFallback) {
      triedFallback = true;
      img.src = getItemImage(itemName, itemName + '.png');
      return;
    }
    img.style.opacity = '0.2';
  };
}

function renderMaterialGrid() {
  materialGrid.innerHTML = '';
  if (!materials.length) return;

  for (var i = 0; i < materials.length; i++) {
    (function(material) {
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'material-btn';

      var img = document.createElement('img');
      setImageWithFallback(img, material.itemName, material.image);
      img.alt = material.label;

      var name = document.createElement('div');
      name.className = 'material-name';
      name.textContent = material.label;

      var stock = document.createElement('div');
      stock.className = 'material-stock';
      stock.textContent = '所持 ' + material.owned;

      if (Number(selectedInputs[material.itemName] || 0) > 0) {
        btn.classList.add('active');
      }
      if (Number(material.owned || 0) <= 0) {
        btn.classList.add('disabled');
        btn.disabled = true;
      }

      btn.appendChild(img);
      btn.appendChild(name);
      btn.appendChild(stock);

      if (!btn.disabled) {
        btn.addEventListener('click', function() {
          addIngredient(material.itemName, 1);
        });
      }

      materialGrid.appendChild(btn);
    })(materials[i]);
  }
}

function renderSelectedList() {
  selectedList.innerHTML = '';
  var hasSelected = false;

  for (var i = 0; i < materials.length; i++) {
    var material = materials[i];
    var count = Number(selectedInputs[material.itemName] || 0);
    if (count < 1) {
      continue;
    }
    hasSelected = true;

    var row = document.createElement('div');
    row.className = 'selected-item';

    var left = document.createElement('div');
    left.className = 'selected-left';

    var img = document.createElement('img');
    setImageWithFallback(img, material.itemName, material.image);
    img.alt = material.label;

    var name = document.createElement('div');
    name.className = 'selected-name';
    name.textContent = material.label;

    var amount = document.createElement('div');
    amount.className = 'selected-count';
    amount.textContent = '投入 x' + count;

    left.appendChild(img);
    left.appendChild(name);

    var controls = document.createElement('div');
    controls.className = 'selected-controls';

    var minus = document.createElement('button');
    minus.type = 'button';
    minus.className = 'step-btn';
    minus.textContent = '-';
    minus.addEventListener('click', function(itemName) {
      return function() {
        addIngredient(itemName, -1);
      };
    }(material.itemName));

    var plus = document.createElement('button');
    plus.type = 'button';
    plus.className = 'step-btn';
    plus.textContent = '+';
    plus.addEventListener('click', function(itemName) {
      return function() {
        addIngredient(itemName, 1);
      };
    }(material.itemName));

    controls.appendChild(minus);
    controls.appendChild(amount);
    controls.appendChild(plus);

    row.appendChild(left);
    row.appendChild(controls);
    selectedList.appendChild(row);
  }

  if (!hasSelected) {
    var empty = document.createElement('div');
    empty.className = 'selected-item';
    empty.textContent = 'まだ素材は投入されていません。左の素材をクリックしてください。';
    selectedList.appendChild(empty);
  }
}

function updateRecipeInfo() {
  if (!materials.length) {
    selectedInfo.textContent = '利用可能な素材がありません';
    recipeInfo.textContent = '';
    materialGrid.innerHTML = '';
    selectedList.innerHTML = '';
    return;
  }

  var selectedKinds = Object.keys(selectedInputs).length;
  selectedInfo.textContent = '投入中の素材: ' + selectedKinds + ' 種類';
  recipeInfo.textContent = 'レシピは非表示です。自由に投入するとサーバー側で判定されます。';
  renderMaterialGrid();
  renderSelectedList();
}

function addIngredient(itemName, delta) {
  var material = null;
  for (var i = 0; i < materials.length; i++) {
    if (materials[i].itemName === itemName) {
      material = materials[i];
      break;
    }
  }
  if (!material) {
    return;
  }

  var current = Number(selectedInputs[itemName] || 0);
  var next = current + Number(delta || 0);
  if (next < 0) next = 0;
  if (next > material.owned) next = material.owned;

  selectedInputs[itemName] = next;
  if (selectedInputs[itemName] <= 0) {
    delete selectedInputs[itemName];
  }

  updateRecipeInfo();
}

function collectInputs() {
  var inputs = {};
  var hasAny = false;

  for (var i = 0; i < materials.length; i++) {
    var material = materials[i];
    var value = Number(selectedInputs[material.itemName] || 0);
    if (value > 0) {
      hasAny = true;
      inputs[material.itemName] = Math.floor(value);
    }
  }

  if (!hasAny) {
    return null;
  }

  return inputs;
}

function submit() {
  var inputs = collectInputs();
  if (!inputs) return;

  post('submitProcess', {
    inputs: inputs
  });

  closeUi();
}

function cancel() {
  post('cancelProcess');
  closeUi();
}

function openUi(payload) {
  materials = (payload && payload.materials) || [];
  selectedInputs = {};
  updateRecipeInfo();
  app.style.display = 'flex';
}

window.addEventListener('message', function(event) {
  var data = event.data;
  if (!data || !data.action) return;

  if (data.action === 'openProcessUi') {
    openUi(data.data || {});
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

