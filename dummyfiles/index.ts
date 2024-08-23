// Incorrect TypeScript file with various issues
import { notExistingFunction } from './nonexistentFile'; // Importing a non-existent module
const num: number = "string"; // Type mismatch: assigning a string to a number

function greet(name: string) {
    console.log("Hello, " + name);
}

greet(42); // Passing a number instead of a string

