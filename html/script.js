(() => {
    const res = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'bsrp-banking';
    const app = document.getElementById('app');
    let quick = [100, 500, 1000, 5000, 10000];

    const $ = (s) => document.querySelector(s);
    const money = (n) => '$' + (Number(n) || 0).toLocaleString('en-US');

    function post(name, data = {}) {
        return fetch(`https://${res}/${name}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify(data),
        }).then((r) => r.json()).catch(() => ({}));
    }

    function fillQuick(containerId, inputId) {
        const el = document.getElementById(containerId);
        el.innerHTML = '';
        quick.forEach((amt) => {
            const b = document.createElement('button');
            b.type = 'button';
            b.className = 'btn tiny';
            b.textContent = money(amt);
            b.addEventListener('click', () => {
                document.getElementById(inputId).value = amt;
            });
            el.appendChild(b);
        });
    }

    function renderHistory(list) {
        const box = $('#historyList');
        if (!list || !list.length) {
            box.innerHTML = '<div class="empty">No transactions yet</div>';
            return;
        }
        box.innerHTML = '';
        list.forEach((e) => {
            const row = document.createElement('div');
            row.className = 'h-row';
            const sign = (e.type === 'deposit' || e.type === 'transfer_in') ? '+' : '−';
            row.innerHTML = `
                <span class="type ${e.type}">${(e.type || '').replace('_', ' ')}</span>
                <span class="amt">${sign}${money(e.amount)}</span>
                <span class="note">${escapeHtml(e.note || '')}</span>
                <span class="when">${escapeHtml(e.label || '')}</span>
            `;
            box.appendChild(row);
        });
    }

    function escapeHtml(s) {
        return String(s)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;');
    }

    function applyData(data) {
        if (!data) return;
        if (data.bankName) $('#bankName').textContent = data.bankName;
        if (data.subtitle) $('#subtitle').textContent = data.subtitle;
        if (data.name) $('#accName').textContent = data.name;
        if (data.bank != null) $('#bankBal').textContent = money(data.bank);
        if (data.cash != null) $('#cashBal').textContent = money(data.cash);
        if (data.quick) {
            quick = data.quick;
            fillQuick('quickDeposit', 'depAmount');
            fillQuick('quickWithdraw', 'wdAmount');
        }
        if (data.history) renderHistory(data.history);
    }

    window.addEventListener('message', (e) => {
        const { action, data, mode } = e.data || {};
        if (action === 'open') {
            app.classList.remove('hidden');
            $('#modeLabel').textContent = (mode || 'bank').toUpperCase();
            applyData(data);
            fillQuick('quickDeposit', 'depAmount');
            fillQuick('quickWithdraw', 'wdAmount');
        } else if (action === 'update') {
            applyData(data);
        } else if (action === 'close') {
            app.classList.add('hidden');
        }
    });

    document.querySelectorAll('.tab').forEach((tab) => {
        tab.addEventListener('click', () => {
            document.querySelectorAll('.tab').forEach((t) => t.classList.remove('active'));
            document.querySelectorAll('.tab-pane').forEach((p) => p.classList.remove('active'));
            tab.classList.add('active');
            const pane = document.getElementById('tab-' + tab.dataset.tab);
            if (pane) pane.classList.add('active');
        });
    });

    $('#btnClose').addEventListener('click', () => post('close'));
    $('#btnRefresh').addEventListener('click', () => post('refresh'));
    $('#btnDeposit').addEventListener('click', () => {
        post('deposit', { amount: Number($('#depAmount').value) || 0 });
        $('#depAmount').value = '';
    });
    $('#btnWithdraw').addEventListener('click', () => {
        post('withdraw', { amount: Number($('#wdAmount').value) || 0 });
        $('#wdAmount').value = '';
    });
    $('#btnTransfer').addEventListener('click', () => {
        post('transfer', {
            target: Number($('#tfTarget').value) || 0,
            amount: Number($('#tfAmount').value) || 0,
            note: $('#tfNote').value || '',
        });
        $('#tfAmount').value = '';
    });

    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape' && !app.classList.contains('hidden')) post('close');
    });
})();
