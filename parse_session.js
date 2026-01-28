const fs = require('fs');
const readline = require('readline');

const filePath = 'C:\\Users\\motha\\AppData\\Roaming\\.claude\\projects\\-home-mothal-Pulpit-Programowanie-Projekty-MyGarage-MyGarage-my-garage\\be13f295-d8a5-4e27-a5aa-369ae751ce28.jsonl';

const messages = [];
let lineCount = 0;

const rl = readline.createInterface({
    input: fs.createReadStream(filePath),
    crlfDelay: Infinity
});

rl.on('line', (line) => {
    lineCount++;
    try {
        const data = JSON.parse(line);

        if (data.type === 'user' || data.type === 'assistant') {
            const message = data.message;
            let text = '';

            if (message && message.content) {
                if (Array.isArray(message.content)) {
                    for (const item of message.content) {
                        if (item.type === 'text' && item.text) {
                            text += item.text;
                        }
                    }
                }
            }

            if (text.trim().length > 0) {
                messages.push({
                    role: data.type,
                    text: text.substring(0, 800), // Limit to 800 chars
                    timestamp: data.timestamp
                });
            }
        }
    } catch (e) {
        // Skip invalid JSON lines
    }
});

rl.on('close', () => {
    console.log(`Total lines processed: ${lineCount}`);
    console.log(`Total messages extracted: ${messages.length}\n`);
    console.log('='.repeat(80));
    console.log('CONVERSATION SUMMARY');
    console.log('='.repeat(80));

    // Print first 20 messages
    console.log('\n--- BEGINNING OF CONVERSATION ---\n');
    for (let i = 0; i < Math.min(20, messages.length); i++) {
        const msg = messages[i];
        console.log(`[${i + 1}] ${msg.role.toUpperCase()} (${msg.timestamp}):`);
        console.log(msg.text);
        console.log('-'.repeat(80));
    }

    // Print last 15 messages
    console.log('\n--- END OF CONVERSATION (Last 15 messages) ---\n');
    const startIdx = Math.max(0, messages.length - 15);
    for (let i = startIdx; i < messages.length; i++) {
        const msg = messages[i];
        console.log(`[${i + 1}] ${msg.role.toUpperCase()} (${msg.timestamp}):`);
        console.log(msg.text);
        console.log('-'.repeat(80));
    }
});
