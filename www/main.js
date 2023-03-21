/* global wasm, wasi, inst */
// import { TextDecoder, TextEncoder } from "util";
import { WASI } from "@bjorn3/browser_wasi_shim/src";


////////////////////////////////////////////////////////////////////////////////
// Haskell Wasm Utilities
////////////////////////////////////////////////////////////////////////////////

function bufferAt(pos, len) {
    return new Uint8Array(exports.memory.buffer, pos, len);
}

function cstringBufferAt(cstr) {
    let b = new Uint8Array(exports.memory.buffer, cstr);
    let l = b.findIndex(i => i == 0, b);
    return bufferAt(cstr, l);
}

function withCStrings(strs, op) {
    const cstrs = strs.map(str => {
        const s = new TextEncoder().encode(str);
        const l = s.length + 1;
        const p = exports.callocBuffer(l);
        const b = new bufferAt(p, l);
        b.set(s);
        return p;
    });
    const r = op(cstrs);
    strs.forEach(exports.freeBuffer);
    return r;
}

function withCString(str, op) {
    return withCStrings([str], strs => op(strs[0]));
}

function fromCString(cstr) {
    const s = new TextDecoder("utf8").decode(cstringBufferAt(cstr));
    exports.freeBuffer(cstr);
    return s;
}

////////////////////////////////////////////////////////////////////////////////
// Application APIs
////////////////////////////////////////////////////////////////////////////////

function echo(str) {
    return fromCString(withCString(str, cstr => exports.echo(cstr)));
}

function store_size() {
    return exports.size();
}

function store_save(k, v) {
    withCStrings([k,v], a => exports.save(a[0], a[1]));
}

function store_load(k) {
    return fromCString(withCString(k, k => exports.load(k)));
}

////////////////////////////////////////////////////////////////////////////////
// Application Logic
////////////////////////////////////////////////////////////////////////////////

const canvas = document.getElementById("canvas");
console.log(canvas);

const width = 20;
const height = 20;

const ctx = canvas.getContext("2d");
const cellSize = 20;

canvas.width = width * cellSize;
canvas.height = height * cellSize;


const wasi = new WASI([], [], []);

function test() {
    console.log("echo:", echo("hello world"));
    console.log("size before", store_size());
    store_save("a", "42");
    store_save("b", "21");
    console.log("size after", store_size());
    console.log("a=", store_load("a"));
    console.log("b=", store_load("b"));
    console.log("c=", store_load("c"));
}
const wasiImportObj = { wasi_snapshot_preview1: wasi.wasiImport };
const wasm = await WebAssembly.instantiateStreaming(fetch("HaskellWASMSnake.wasm"), wasiImportObj);
wasi.inst = wasm.instance;
const exports = wasm.instance.exports;
// initialize Haskell Wasm Reactor Module
exports._initialize();
exports.hs_init(0, 0);


(async function () {
    
    // load Haskell Wasm Reactor Module
    // window.wasm = await WebAssembly.compileStreaming(fetch("HaskellWASMSnake.wasm"));
    // window.wasi = new WASI([], ["LC_ALL=en_US.utf-8"], [/* fds */]);
    // window.inst = await WebAssembly.instantiate(wasm, {
    //     "wasi_snapshot_preview1": wasi.wasiImport,
    // });
    window.isRunning = true;
    test();
    update();
})()


document.addEventListener("keydown", event => {
    window.direction = event.key;
    console.log(event.key);
});

// window.start = () => {
//     window.isRunning = true;
//     console.log('start');
//     console.log(window);
//     update();
// };

window.stop = () => {
    window.isRunning = false;
};

// function init() {
//     window.start();
// }


async function update() {

    if (!window.direction) {
        window.direction = 's';
    }

    store_save("input", window.direction);
    exports.updateGameStateIO();
    const output = store_load("output");

    draw(output);
    // delay
    await new Promise(resolve => setTimeout(resolve, 150));

    console.log('update');
    console.log(window);
    if (window.isRunning) {
        window.requestAnimationFrame(update);
    }
}

function draw(gameStateStr) {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    const rows = gameStateStr.trim().split('\n');
    console.log(rows)

    for (let y = 0; y < height; y++) {
        for (let x = 0; x < width; x++) {
        const c = rows[y][x];
        if (c === '*') {
            ctx.fillStyle = 'black';
            ctx.fillRect(x * cellSize, y * cellSize, cellSize, cellSize);
        } else if (c === '@') {
            ctx.fillStyle = 'red';
            ctx.fillRect(x * cellSize, y * cellSize, cellSize, cellSize);
        }

        }
    }
}


