// Run every existing identity check, retaining a failing exit code for any mismatch.
const fs = require('node:fs');
const path = require('node:path');
const Module = require('node:module');
const filename = path.join(__dirname, 'audit_khidma_identity.cjs');
const original = fs.readFileSync(filename, 'utf8');
const target = 'function check(name, action) { action(); checks++; console.log(`PASS ${name}`); }';
if (!original.includes(target)) throw new Error('Identity audit structure changed');
const source = original.replace(target,
  'function check(name, action) { try { action(); checks++; console.log(`PASS ${name}`); } catch (error) { console.error(`FAIL ${name}: ${error.message}`); process.exitCode = 1; } }');
const audit = new Module(filename, module);
audit.filename = filename;
audit.paths = module.paths;
audit._compile(source, filename);
