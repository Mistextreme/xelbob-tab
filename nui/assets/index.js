try {
    const date = new Date();

    function isSafeUrl(url) {
        try {
            const urlObj = new URL(url);
            if (!['http:', 'https:'].includes(urlObj.protocol)) {
                return false;
            }
            return true;
        } catch (e) {
            return false;
        }
    }

    function importPage(infos) {
        const pages = document.getElementById('pages');

        const divPage = document.createElement('div');
        divPage.classList.add('page');
        divPage.setAttribute('v-if', `currentPage == "${infos.href}"`);
        divPage.setAttribute('id', infos.href);

        const content = document.createElement('div');
        content.classList.add('content');

        if ('url' in infos) {
            if (isSafeUrl(infos.url)) {
                const iframe = document.createElement('iframe');
                iframe.src = infos.url;
                iframe.classList.add('opencad');
                content.appendChild(iframe);
            }
        } else if (infos.href === 'calculatorapp') {
            let calcInput = '';
            let calcOn = false;

            const style = document.createElement('style');
            style.innerHTML = `
                .calculator {
                    background-color: #333;
                    border: 2px solid #444;
                    border-radius: 10px;
                    overflow: hidden;
                    width: 320px;
                    margin: 40px auto 0;
                    box-shadow: 0 4px 8px rgba(0,0,0,0.3);
                }
                #calc-display {
                    display: block;
                    width: 100%;
                    box-sizing: border-box;
                    margin-bottom: 10px;
                    padding: 10px;
                    font-size: 24px;
                    background-color: #444;
                    border: none;
                    color: #fff;
                    border-radius: 8px;
                    text-align: right;
                    outline: none;
                }
                .calc-buttons {
                    display: grid;
                    grid-template-columns: repeat(4, 1fr);
                    gap: 10px;
                    padding: 10px;
                }
                .calc-buttons button {
                    width: 100%;
                    height: 60px;
                    font-size: 18px;
                    border: none;
                    border-radius: 8px;
                    cursor: pointer;
                    transition: background-color 0.3s ease;
                    outline: none;
                    color: #fff;
                    background-color: #e74c3c;
                }
                .calc-buttons button:hover  { filter: brightness(1.2); }
                .calc-buttons button:active { filter: brightness(0.8); }
                .calc-btn-zero { grid-column: span 2; }
            `;
            document.head.appendChild(style);

            const wrap = document.createElement('div');
            wrap.classList.add('calculator');

            const display = document.createElement('input');
            display.type = 'text';
            display.id = 'calc-display';
            display.disabled = true;
            wrap.appendChild(display);

            const grid = document.createElement('div');
            grid.classList.add('calc-buttons');

            function updateDisplay() {
                display.value = calcOn ? (calcInput || '0') : '';
            }

            function makeBtn(label, extraClass, handler) {
                const btn = document.createElement('button');
                btn.textContent = label;
                if (extraClass) btn.classList.add(extraClass);
                btn.addEventListener('click', handler);
                grid.appendChild(btn);
            }

            makeBtn('C', null, () => { if (calcOn) { calcInput = ''; updateDisplay(); } });
            makeBtn('CE', null, () => { if (calcOn) { calcInput = calcInput.slice(0, -1); updateDisplay(); } });
            makeBtn('ON/OFF', null, () => { calcOn = !calcOn; calcInput = ''; updateDisplay(); });
            makeBtn('÷', null, () => { if (calcOn) { calcInput += '/'; updateDisplay(); } });
            ['7','8','9'].forEach(n => makeBtn(n, null, () => { if (calcOn) { calcInput += n; updateDisplay(); } }));
            makeBtn('×', null, () => { if (calcOn) { calcInput += '*'; updateDisplay(); } });
            ['4','5','6'].forEach(n => makeBtn(n, null, () => { if (calcOn) { calcInput += n; updateDisplay(); } }));
            makeBtn('-', null, () => { if (calcOn) { calcInput += '-'; updateDisplay(); } });
            ['1','2','3'].forEach(n => makeBtn(n, null, () => { if (calcOn) { calcInput += n; updateDisplay(); } }));
            makeBtn('+', null, () => { if (calcOn) { calcInput += '+'; updateDisplay(); } });
            makeBtn('0', 'calc-btn-zero', () => { if (calcOn) { calcInput += '0'; updateDisplay(); } });
            makeBtn('=', null, () => {
                if (!calcOn) return;
                try {
                    calcInput = eval(calcInput).toString();
                } catch (e) {
                    calcInput = 'Erreur';
                }
                updateDisplay();
            });
            makeBtn('.', null, () => { if (calcOn) { calcInput += '.'; updateDisplay(); } });

            wrap.appendChild(grid);
            content.appendChild(wrap);

        } else if (infos.href === 'noteapp') {
            const noteContent = document.createElement('div');
            noteContent.innerHTML = `
                <h1>Prise de Notes</h1>
                <textarea id="note-textarea" rows="10" cols="50" placeholder="Écrivez vos notes ici..."></textarea>
                <div class='note-buttons'>
                    <button class="save-note">Sauvegarder</button>
                    <button class="clear-note">Effacer</button>
                </div>
            `;

            const style = document.createElement('style');
            style.innerHTML = `
                #note-textarea {
                    width: 100%;
                    padding: 10px;
                    font-size: 16px;
                    border-radius: 8px;
                    border: 1px solid #ccc;
                    resize: none;
                }
                .note-buttons {
                    margin-top: 10px;
                }
                .note-buttons button {
                    margin-right: 10px;
                    padding: 10px 20px;
                    border: none;
                    border-radius: 5px;
                    background-color: #f2a922;
                    color: #fff;
                    cursor: pointer;
                    transition: background-color 0.3s;
                }
                .note-buttons button:hover {
                    background-color: #121619;
                }
            `;

            content.appendChild(noteContent);
            document.head.appendChild(style);

            noteContent.querySelector('.save-note').addEventListener('click', () => {
                const noteText = noteContent.querySelector('#note-textarea').value;
                localStorage.setItem('note', noteText);
                alert('Note sauvegardée !');
            });

            noteContent.querySelector('.clear-note').addEventListener('click', () => {
                noteContent.querySelector('#note-textarea').value = '';
                localStorage.removeItem('note');
                alert('Note effacée !');
            });

            const savedNote = localStorage.getItem('note');
            if (savedNote) {
                noteContent.querySelector('#note-textarea').value = savedNote;
            }

        } else {
            const iframe = document.createElement('iframe');
            iframe.src = 'https://xelyos.fr';
            iframe.classList.add('opencad');
            content.appendChild(iframe);
        }

        divPage.appendChild(content);
        pages.appendChild(divPage);
    }

    const lastPage = localStorage.getItem('tablet_lastPage') || 'main';

    config.DefaultSites.forEach(site => {
        importPage(site);
    });

    const app = new Vue({
        el: '#tablet',
        data: {
            opened: false,
            currentPage: lastPage,
            Calendar: {
                day: date.toLocaleDateString('fr-FR', { weekday: 'long' }),
                date: date.getDate()
            },
            Applications: [],
            Weather: {
                icon: 'weather-icon fas fa-sun',
                condition: '',
                temp: '22',
                background: '',
                truefalse: 'weather-widgetb'
            },
        },
        mounted() {
            let initial = document.getElementById(this.currentPage);
            if (initial) {
                initial.style.opacity = 1;
            }
        },
        methods: {
            async post(url, data = {}) {
                const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(data)
                });
                return await response.json();
            },
            setPageOpacity(id, value) {
                let page = document.getElementById(id);
                if (page && page.style) {
                    page.style.opacity = value;
                }
            },
            switchPage(page) {
                if (this.currentPage === page) return;
                this.setPageOpacity(this.currentPage, 0);
                this.currentPage = page;
                localStorage.setItem('tablet_lastPage', page);
                setTimeout(() => { this.setPageOpacity(page, 1); }, 50);
            },
            openNotes() {
                this.switchPage('noteapp');
            }
        }
    });

    window.addEventListener('message', async ({ data }) => {
        switch (data.action) {
            case 'open':
                app.Applications = data.apps || [];
                app.opened = true;
                app.Weather.condition = data.weather;
                app.Weather.icon = data.icon;
                app.Weather.temp = data.temp;
                app.Weather.background = data.background;
                app.Weather.truefalse = data.truefalse;
                
                if (data.apps && Array.isArray(data.apps)) {
                    data.apps.forEach(site => {
                        if (!document.getElementById(site.href)) {
                            importPage(site);
                        }
                    });
                }
                break;
            case 'close':
                app.opened = false;
                break;
        }
    });

    window.addEventListener('keydown', (event) => {
        const key = event.key;
        if (key.toLowerCase() === 'escape') {
            app.post('close');
        }
        if (key === 'Tab') {
            event.preventDefault();
        }
    });

} catch (error) {
}
