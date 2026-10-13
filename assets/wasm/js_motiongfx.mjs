/* @ts-self-types="./js_motiongfx.d.ts" */

export class BarsDemo {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        BarsDemoFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_barsdemo_free(ptr, 0);
    }
    /**
     * @returns {number}
     */
    get duration() {
        const ret = wasm.barsdemo_duration(this.__wbg_ptr);
        return ret;
    }
    constructor() {
        const ret = wasm.barsdemo_new();
        this.__wbg_ptr = ret;
        BarsDemoFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
    /**
     * @param {number} seconds
     */
    sampleAt(seconds) {
        wasm.barsdemo_sampleAt(this.__wbg_ptr, seconds);
    }
    /**
     * Every shape this demo draws, flattened for `mgfx-demo.js`'s
     * generic renderer; see `shape.rs`.
     * @returns {Float64Array}
     */
    shapes() {
        const ret = wasm.barsdemo_shapes(this.__wbg_ptr);
        var v1 = getArrayF64FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 8, 8);
        return v1;
    }
}
if (Symbol.dispose) BarsDemo.prototype[Symbol.dispose] = BarsDemo.prototype.free;

export class BounceDemo {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        BounceDemoFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_bouncedemo_free(ptr, 0);
    }
    /**
     * @returns {number}
     */
    get duration() {
        const ret = wasm.bouncedemo_duration(this.__wbg_ptr);
        return ret;
    }
    constructor() {
        const ret = wasm.bouncedemo_new();
        this.__wbg_ptr = ret;
        BounceDemoFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
    /**
     * @param {number} seconds
     */
    sampleAt(seconds) {
        wasm.bouncedemo_sampleAt(this.__wbg_ptr, seconds);
    }
    /**
     * Every shape this demo draws, flattened for `mgfx-demo.js`'s
     * generic renderer; see `shape.rs`.
     * @returns {Float64Array}
     */
    shapes() {
        const ret = wasm.bouncedemo_shapes(this.__wbg_ptr);
        var v1 = getArrayF64FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 8, 8);
        return v1;
    }
}
if (Symbol.dispose) BounceDemo.prototype[Symbol.dispose] = BounceDemo.prototype.free;

/**
 * Easing curve, matching `motiongfx::prelude::ease`.
 * @enum {0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24 | 25 | 26 | 27}
 */
export const Ease = Object.freeze({
    Linear: 0, "0": "Linear",
    SineIn: 1, "1": "SineIn",
    SineOut: 2, "2": "SineOut",
    SineInOut: 3, "3": "SineInOut",
    QuadIn: 4, "4": "QuadIn",
    QuadOut: 5, "5": "QuadOut",
    QuadInOut: 6, "6": "QuadInOut",
    CubicIn: 7, "7": "CubicIn",
    CubicOut: 8, "8": "CubicOut",
    CubicInOut: 9, "9": "CubicInOut",
    QuartIn: 10, "10": "QuartIn",
    QuartOut: 11, "11": "QuartOut",
    QuartInOut: 12, "12": "QuartInOut",
    QuintIn: 13, "13": "QuintIn",
    QuintOut: 14, "14": "QuintOut",
    QuintInOut: 15, "15": "QuintInOut",
    ExpoIn: 16, "16": "ExpoIn",
    ExpoOut: 17, "17": "ExpoOut",
    ExpoInOut: 18, "18": "ExpoInOut",
    CircIn: 19, "19": "CircIn",
    CircOut: 20, "20": "CircOut",
    CircInOut: 21, "21": "CircInOut",
    BackIn: 22, "22": "BackIn",
    BackOut: 23, "23": "BackOut",
    BackInOut: 24, "24": "BackInOut",
    ElasticIn: 25, "25": "ElasticIn",
    ElasticOut: 26, "26": "ElasticOut",
    ElasticInOut: 27, "27": "ElasticInOut",
});

/**
 * An action or combinator not yet resolved into a `TrackFragment`. Build
 * one with [`act`], [`chain`], [`all`], [`any`], [`flow`], or [`delay`],
 * and hand the root to [`compile`].
 */
export class Fragment {
    static __wrap(ptr) {
        const obj = Object.create(Fragment.prototype);
        obj.__wbg_ptr = ptr;
        FragmentFinalization.register(obj, obj.__wbg_ptr, obj);
        return obj;
    }
    static __unwrap(jsValue) {
        if (!(jsValue instanceof Fragment)) {
            return 0;
        }
        return jsValue.__destroy_into_raw();
    }
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        FragmentFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_fragment_free(ptr, 0);
    }
}
if (Symbol.dispose) Fragment.prototype[Symbol.dispose] = Fragment.prototype.free;

export class RelativeDemo {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        RelativeDemoFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_relativedemo_free(ptr, 0);
    }
    /**
     * @returns {number}
     */
    get duration() {
        const ret = wasm.relativedemo_duration(this.__wbg_ptr);
        return ret;
    }
    constructor() {
        const ret = wasm.relativedemo_new();
        this.__wbg_ptr = ret;
        RelativeDemoFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
    /**
     * @param {number} seconds
     */
    sampleAt(seconds) {
        wasm.relativedemo_sampleAt(this.__wbg_ptr, seconds);
    }
    /**
     * Every shape this demo draws, flattened for
     * `mgfx-demo.js`'s generic renderer; see
     * `shape.rs`.
     * @returns {Float64Array}
     */
    shapes() {
        const ret = wasm.relativedemo_shapes(this.__wbg_ptr);
        var v1 = getArrayF64FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 8, 8);
        return v1;
    }
}
if (Symbol.dispose) RelativeDemo.prototype[Symbol.dispose] = RelativeDemo.prototype.free;

/**
 * A scope for signals and the timeline compiled from them. Create
 * signals with [`Self::create_signal`], resolve a [`Fragment`] tree
 * built from `act`/`chain`/`all`/`any`/`flow`/`delay` with
 * [`Self::compile`], then scrub it with [`Self::sample_at`] and read
 * values back with [`Self::get`].
 */
export class Runtime {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        RuntimeFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_runtime_free(ptr, 0);
    }
    /**
     * Resolves, plays, orders, compiles, and bakes a timeline from `root`.
     * @param {Fragment} root
     */
    compile(root) {
        _assertClass(root, Fragment);
        var ptr0 = root.__destroy_into_raw();
        wasm.runtime_compile(this.__wbg_ptr, ptr0);
    }
    /**
     * Registers a named subject with an initial value, returning its id.
     * @param {string} name
     * @param {number} initial
     * @returns {number}
     */
    createSignal(name, initial) {
        const ptr0 = passStringToWasm0(name, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.runtime_createSignal(this.__wbg_ptr, ptr0, len0, initial);
        return ret >>> 0;
    }
    /**
     * The compiled track's duration, in seconds.
     * @returns {number}
     */
    get duration() {
        const ret = wasm.runtime_duration(this.__wbg_ptr);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0];
    }
    /**
     * Reads a signal's current value straight from the world (does not
     * itself sample; call after `sampleAt`).
     * @param {number} id
     * @returns {number}
     */
    get(id) {
        const ret = wasm.runtime_get(this.__wbg_ptr, id);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0];
    }
    constructor() {
        const ret = wasm.runtime_new();
        this.__wbg_ptr = ret;
        RuntimeFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
    /**
     * Moves the playhead and samples. Call before reading any signal.
     * @param {number} seconds
     */
    sampleAt(seconds) {
        const ret = wasm.runtime_sampleAt(this.__wbg_ptr, seconds);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
}
if (Symbol.dispose) Runtime.prototype[Symbol.dispose] = Runtime.prototype.free;

/**
 * Describes animating subject `id` to `to` (a target value, or a
 * function of its current value) over `duration_secs`.
 * @param {number} id
 * @param {any} to
 * @param {number} duration_secs
 * @param {Ease | null} [ease]
 * @returns {Fragment}
 */
export function act(id, to, duration_secs, ease) {
    const ret = wasm.act(id, to, duration_secs, isLikeNone(ease) ? 28 : ease);
    return Fragment.__wrap(ret);
}

/**
 * Runs fragments together; finishes when the slowest one does.
 * @param {Fragment[]} fragments
 * @returns {Fragment}
 */
export function all(fragments) {
    const ptr0 = passArrayJsValueToWasm0(fragments, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.all(ptr0, len0);
    return Fragment.__wrap(ret);
}

/**
 * Runs fragments together; finishes as soon as the fastest one does.
 * @param {Fragment[]} fragments
 * @returns {Fragment}
 */
export function any(fragments) {
    const ptr0 = passArrayJsValueToWasm0(fragments, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.any(ptr0, len0);
    return Fragment.__wrap(ret);
}

/**
 * Runs fragments one after another; the next starts when the previous finishes.
 * @param {Fragment[]} fragments
 * @returns {Fragment}
 */
export function chain(fragments) {
    const ptr0 = passArrayJsValueToWasm0(fragments, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.chain(ptr0, len0);
    return Fragment.__wrap(ret);
}

/**
 * Pushes a single fragment's start later.
 * @param {number} delay_secs
 * @param {Fragment} fragment
 * @returns {Fragment}
 */
export function delay(delay_secs, fragment) {
    _assertClass(fragment, Fragment);
    var ptr0 = fragment.__destroy_into_raw();
    const ret = wasm.delay(delay_secs, ptr0);
    return Fragment.__wrap(ret);
}

/**
 * Like `chain`, but each fragment starts a fixed delay after the previous one starts.
 * @param {number} delay_secs
 * @param {Fragment[]} fragments
 * @returns {Fragment}
 */
export function flow(delay_secs, fragments) {
    const ptr0 = passArrayJsValueToWasm0(fragments, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.flow(delay_secs, ptr0, len0);
    return Fragment.__wrap(ret);
}
function __wbg_get_imports() {
    const import0 = {
        __proto__: null,
        __wbg___wbindgen_is_function_fcda5e3902d732fe: function(arg0) {
            const ret = typeof(arg0) === 'function';
            return ret;
        },
        __wbg___wbindgen_number_get_1dc732b810cb937c: function(arg0, arg1) {
            const obj = arg1;
            const ret = typeof(obj) === 'number' ? obj : undefined;
            getDataViewMemory0().setFloat64(arg0 + 8 * 1, isLikeNone(ret) ? 0 : ret, true);
            getDataViewMemory0().setInt32(arg0 + 4 * 0, !isLikeNone(ret), true);
        },
        __wbg___wbindgen_throw_5d9e815e6fdf150f: function(arg0, arg1) {
            throw new Error(getStringFromWasm0(arg0, arg1));
        },
        __wbg_call_6bcf8d3e20937e46: function() { return handleError(function (arg0, arg1, arg2) {
            const ret = arg0.call(arg1, arg2);
            return ret;
        }, arguments); },
        __wbg_fragment_unwrap: function(arg0) {
            const ret = Fragment.__unwrap(arg0);
            return ret;
        },
        __wbindgen_generic_0000000000000001: function(arg0) {
            // Cast intrinsic for `F64 -> Externref`.
            const ret = arg0;
            return ret;
        },
        __wbindgen_generic_0000000000000002: function(arg0, arg1) {
            // Cast intrinsic for `Ref(String) -> Externref`.
            const ret = getStringFromWasm0(arg0, arg1);
            return ret;
        },
        __wbindgen_init_externref_table: function() {
            const table = wasm.__wbindgen_externrefs;
            const offset = table.grow(4);
            table.set(0, undefined);
            table.set(offset + 0, undefined);
            table.set(offset + 1, null);
            table.set(offset + 2, true);
            table.set(offset + 3, false);
        },
    };
    return {
        __proto__: null,
        "./js_motiongfx_bg.js": import0,
    };
}

const BarsDemoFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_barsdemo_free(ptr, 1));
const BounceDemoFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_bouncedemo_free(ptr, 1));
const FragmentFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_fragment_free(ptr, 1));
const RelativeDemoFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_relativedemo_free(ptr, 1));
const RuntimeFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_runtime_free(ptr, 1));

function addToExternrefTable0(obj) {
    const idx = wasm.__externref_table_alloc();
    wasm.__wbindgen_externrefs.set(idx, obj);
    return idx;
}

function _assertClass(instance, klass) {
    if (!(instance instanceof klass)) {
        throw new Error(`expected instance of ${klass.name}`);
    }
}

function getArrayF64FromWasm0(ptr, len) {
    ptr = ptr >>> 0;
    return getFloat64ArrayMemory0().subarray(ptr / 8, ptr / 8 + len);
}

let cachedDataViewMemory0 = null;
function getDataViewMemory0() {
    if (cachedDataViewMemory0 === null || cachedDataViewMemory0.buffer.detached === true || (cachedDataViewMemory0.buffer.detached === undefined && cachedDataViewMemory0.buffer !== wasm.memory.buffer)) {
        cachedDataViewMemory0 = new DataView(wasm.memory.buffer);
    }
    return cachedDataViewMemory0;
}

let cachedFloat64ArrayMemory0 = null;
function getFloat64ArrayMemory0() {
    if (cachedFloat64ArrayMemory0 === null || cachedFloat64ArrayMemory0.byteLength === 0) {
        cachedFloat64ArrayMemory0 = new Float64Array(wasm.memory.buffer);
    }
    return cachedFloat64ArrayMemory0;
}

function getStringFromWasm0(ptr, len) {
    return decodeText(ptr >>> 0, len);
}

let cachedUint8ArrayMemory0 = null;
function getUint8ArrayMemory0() {
    if (cachedUint8ArrayMemory0 === null || cachedUint8ArrayMemory0.byteLength === 0) {
        cachedUint8ArrayMemory0 = new Uint8Array(wasm.memory.buffer);
    }
    return cachedUint8ArrayMemory0;
}

function handleError(f, args) {
    try {
        return f.apply(this, args);
    } catch (e) {
        const idx = addToExternrefTable0(e);
        wasm.__wbindgen_exn_store(idx);
    }
}

function isLikeNone(x) {
    return x === undefined || x === null;
}

function passArrayJsValueToWasm0(array, malloc) {
    const ptr = malloc(array.length * 4, 4) >>> 0;
    for (let i = 0; i < array.length; i++) {
        const add = addToExternrefTable0(array[i]);
        getDataViewMemory0().setUint32(ptr + 4 * i, add, true);
    }
    WASM_VECTOR_LEN = array.length;
    return ptr;
}

function passStringToWasm0(arg, malloc, realloc) {
    if (realloc === undefined) {
        const buf = cachedTextEncoder.encode(arg);
        const ptr = malloc(buf.length, 1) >>> 0;
        getUint8ArrayMemory0().subarray(ptr, ptr + buf.length).set(buf);
        WASM_VECTOR_LEN = buf.length;
        return ptr;
    }

    let len = arg.length;
    let ptr = malloc(len, 1) >>> 0;

    const mem = getUint8ArrayMemory0();

    let offset = 0;

    for (; offset < len; offset++) {
        const code = arg.charCodeAt(offset);
        if (code > 0x7F) break;
        mem[ptr + offset] = code;
    }
    if (offset !== len) {
        if (offset !== 0) {
            arg = arg.slice(offset);
        }
        ptr = realloc(ptr, len, len = offset + arg.length * 3, 1) >>> 0;
        const view = getUint8ArrayMemory0().subarray(ptr + offset, ptr + len);
        const ret = cachedTextEncoder.encodeInto(arg, view);

        offset += ret.written;
        ptr = realloc(ptr, len, offset, 1) >>> 0;
    }

    WASM_VECTOR_LEN = offset;
    return ptr;
}

function takeFromExternrefTable0(idx) {
    const value = wasm.__wbindgen_externrefs.get(idx);
    wasm.__externref_table_dealloc(idx);
    return value;
}

let cachedTextDecoder = new TextDecoder('utf-8', { ignoreBOM: true, fatal: true });
cachedTextDecoder.decode();
const MAX_SAFARI_DECODE_BYTES = 2146435072;
let numBytesDecoded = 0;
function decodeText(ptr, len) {
    numBytesDecoded += len;
    if (numBytesDecoded >= MAX_SAFARI_DECODE_BYTES) {
        cachedTextDecoder = new TextDecoder('utf-8', { ignoreBOM: true, fatal: true });
        cachedTextDecoder.decode();
        numBytesDecoded = len;
    }
    return cachedTextDecoder.decode(getUint8ArrayMemory0().subarray(ptr, ptr + len));
}

const cachedTextEncoder = new TextEncoder();

if (!('encodeInto' in cachedTextEncoder)) {
    cachedTextEncoder.encodeInto = function (arg, view) {
        const buf = cachedTextEncoder.encode(arg);
        view.set(buf);
        return {
            read: arg.length,
            written: buf.length
        };
    };
}

let WASM_VECTOR_LEN = 0;

let wasmModule, wasmInstance, wasm;
function __wbg_finalize_init(instance, module) {
    wasmInstance = instance;
    wasm = instance.exports;
    wasmModule = module;
    cachedDataViewMemory0 = null;
    cachedFloat64ArrayMemory0 = null;
    cachedUint8ArrayMemory0 = null;
    wasm.__wbindgen_start();
    return wasm;
}

async function __wbg_load(module, imports) {
    if (typeof Response === 'function' && module instanceof Response) {
        if (!module.ok) {
            throw new Error(`failed to fetch Wasm: ${module.status} ${module.statusText} fetching '${module.url}'`);
        }

        if (typeof WebAssembly.instantiateStreaming === 'function') {
            try {
                return await WebAssembly.instantiateStreaming(module, imports);
            } catch (e) {
                const validResponse = expectedResponseType(module.type);

                if (validResponse && module.headers.get('Content-Type') !== 'application/wasm') {
                    console.warn("`WebAssembly.instantiateStreaming` failed because your server does not serve Wasm with `application/wasm` MIME type. Falling back to `WebAssembly.instantiate` which is slower. Original error:\n", e);

                } else { throw e; }
            }
        }

        const bytes = await module.arrayBuffer();
        return await WebAssembly.instantiate(bytes, imports);
    } else {
        const instance = await WebAssembly.instantiate(module, imports);

        if (instance instanceof WebAssembly.Instance) {
            return { instance, module };
        } else {
            return instance;
        }
    }

    function expectedResponseType(type) {
        switch (type) {
            case 'basic': case 'cors': case 'default': return true;
        }
        return false;
    }
}

function initSync(module) {
    if (wasm !== undefined) return wasm;


    if (module !== undefined) {
        if (Object.getPrototypeOf(module) === Object.prototype) {
            ({module} = module)
        } else {
            console.warn('using deprecated parameters for `initSync()`; pass a single object instead')
        }
    }

    const imports = __wbg_get_imports();
    if (!(module instanceof WebAssembly.Module)) {
        module = new WebAssembly.Module(module);
    }
    const instance = new WebAssembly.Instance(module, imports);
    return __wbg_finalize_init(instance, module);
}

async function __wbg_init(module_or_path) {
    if (wasm !== undefined) return wasm;


    if (module_or_path !== undefined) {
        if (Object.getPrototypeOf(module_or_path) === Object.prototype) {
            ({module_or_path} = module_or_path)
        } else {
            console.warn('using deprecated parameters for the initialization function; pass a single object instead')
        }
    }

    if (module_or_path === undefined) {
        module_or_path = new URL('js_motiongfx_bg.wasm', import.meta.url);
    }
    const imports = __wbg_get_imports();

    if (typeof module_or_path === 'string' || (typeof Request === 'function' && module_or_path instanceof Request) || (typeof URL === 'function' && module_or_path instanceof URL)) {
        module_or_path = fetch(module_or_path);
    }

    const { instance, module } = await __wbg_load(await module_or_path, imports);

    return __wbg_finalize_init(instance, module);
}

export { initSync, __wbg_init as default };
