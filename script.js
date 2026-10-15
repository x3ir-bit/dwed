let selectedContract = null;
let contracts = [];
let onCooldown = false;
let parts = [];
let activeTab = 'contracts';

function updateRefreshButton() {
    const btn = document.getElementById('btn-refresh');
    if (btn) btn.disabled = onCooldown;
}

function renderContracts() {
    const grid = document.getElementById('contracts-grid');
    grid.innerHTML = '';
    contracts.forEach((contract) => {
        const card = document.createElement('div');
        card.className = 'contract-card' + (selectedContract === contract.id ? ' selected' : '');
        card.dataset.id = contract.id;
        card.innerHTML = `
            <div class="contract-vehicle">
                <img class="contract-vehicle-img" src="images/${contract.vehicle}.png" alt="${contract.vehicle}" onerror="this.src='images/placeholder.png'">
                <div class="contract-vehicle-name">${contract.vehicle.replace(/_/g, ' ')}</div>
            </div>
            <div class="contract-reward">
                <span class="contract-reward-amount">$${contract.reward.toLocaleString()}</span>
                <button class="contract-accept-btn" data-id="${contract.id}">Accept</button>
            </div>
        `;
        card.addEventListener('click', (e) => {
            if (e.target.classList.contains('contract-accept-btn')) {
                acceptContract(contract.id);
            } else {
                selectContract(contract.id);
            }
        });
        grid.appendChild(card);
    });
}

function renderParts() {
    const grid = document.getElementById('parts-grid');
    grid.innerHTML = '';
    if (parts.length === 0) {
        grid.innerHTML = '<div class="no-parts">No parts to sell. Chop a car first!</div>';
        return;
    }
    parts.forEach((part, idx) => {
        const card = document.createElement('div');
        card.className = 'part-card';
        card.innerHTML = `
            <div class="part-info">
                <span class="part-name">${part.label}</span>
                <span class="part-count">x${part.count}</span>
            </div>
            <div class="part-reward">
                <span class="part-price">$${(part.price * part.count).toLocaleString()}</span>
                <button class="part-sell-btn" data-idx="${idx}">Sell</button>
            </div>
        `;
        card.querySelector('.part-sell-btn').addEventListener('click', () => {
            sellPart(part);
        });
        grid.appendChild(card);
    });
}

function selectContract(id) {
    selectedContract = id;
    document.querySelectorAll('.contract-card').forEach(card => {
        card.classList.toggle('selected', parseInt(card.dataset.id) === id);
    });
}

function acceptContract(id) {
    fetch(`https://${GetParentResourceName()}/accept`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ contractId: id })
    });
}

function sellPart(part) {
    fetch(`https://${GetParentResourceName()}/sellParts`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ items: [{ name: part.name, count: part.count }] })
    });
}

function switchTab(tab) {
    activeTab = tab;
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
    document.getElementById(`tab-${tab}`).classList.add('active');
    document.getElementById(`tab-btn-${tab}`).classList.add('active');
}

document.getElementById('tab-btn-contracts').addEventListener('click', () => switchTab('contracts'));
document.getElementById('tab-btn-sell').addEventListener('click', () => switchTab('sell'));

document.getElementById('btn-close').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/close`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({}) });
});

document.getElementById('btn-minimize').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/minimize`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({}) });
});

document.getElementById('btn-maximize').addEventListener('click', () => {
    const win = document.querySelector('.macos-window');
    if (win.style.width === '850px') {
        win.style.width = '680px';
        win.style.maxHeight = '520px';
    } else {
        win.style.width = '850px';
        win.style.maxHeight = '600px';
    }
});

document.getElementById('btn-refresh').addEventListener('click', () => {
    if (!onCooldown) {
        fetch(`https://${GetParentResourceName()}/refresh`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({}) });
    }
});

window.addEventListener('message', ({ data }) => {
    const app = document.getElementById('app');
    switch (data.action) {
        case 'open':
            app.classList.remove('hidden');
            contracts = data.contracts;
            parts = data.parts || [];
            onCooldown = data.onCooldown;
            document.getElementById('window-title').textContent = data.title;
            renderContracts();
            renderParts();
            updateRefreshButton();
            break;
        case 'close':
            app.classList.add('hidden');
            selectedContract = null;
            break;
        case 'updateContracts':
            contracts = data.contracts;
            selectedContract = null;
            renderContracts();
            break;
        case 'updateParts':
            parts = data.parts || [];
            renderParts();
            break;
        case 'cooldownTick':
            onCooldown = data.onCooldown;
            const timer = document.getElementById('cooldown-timer');
            timer.textContent = data.onCooldown && data.remaining > 0 ? `${data.remaining}s` : '';
            updateRefreshButton();
            break;
    }
});   