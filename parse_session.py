import json
import sys
import codecs

# Force UTF-8 output on Windows
sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'ignore')

file_path = r"C:\Users\motha\AppData\Roaming\.claude\projects\-home-mothal-Pulpit-Programowanie-Projekty-MyGarage-MyGarage-my-garage\be13f295-d8a5-4e27-a5aa-369ae751ce28.jsonl"

messages = []
line_count = 0

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        for line in f:
            line_count += 1
            try:
                data = json.loads(line)

                if data.get('type') in ['user', 'assistant']:
                    message = data.get('message', {})
                    text = ''

                    if isinstance(message, dict):
                        content = message.get('content', [])
                        if isinstance(content, list):
                            for item in content:
                                if isinstance(item, dict) and item.get('type') == 'text':
                                    text += item.get('text', '')

                    if text.strip():
                        messages.append({
                            'role': data['type'],
                            'text': text[:800],  # Limit to 800 chars
                            'timestamp': data.get('timestamp', '')
                        })
            except json.JSONDecodeError:
                continue
            except Exception as e:
                continue

    print(f"Total lines processed: {line_count}")
    print(f"Total messages extracted: {len(messages)}\n")
    print('=' * 80)
    print('CONVERSATION SUMMARY')
    print('=' * 80)

    # Print first 25 messages
    print('\n--- BEGINNING OF CONVERSATION ---\n')
    for i, msg in enumerate(messages[:25], 1):
        print(f"[{i}] {msg['role'].upper()} ({msg['timestamp']}):")
        print(msg['text'])
        print('-' * 80)

    # Print middle section (messages around 100-120)
    print('\n--- MIDDLE OF CONVERSATION (Messages 100-120) ---\n')
    for i, msg in enumerate(messages[99:120], 100):
        print(f"[{i}] {msg['role'].upper()} ({msg['timestamp']}):")
        print(msg['text'])
        print('-' * 80)

    # Print last 20 messages
    print('\n--- END OF CONVERSATION (Last 20 messages) ---\n')
    for i, msg in enumerate(messages[-20:], len(messages) - 19):
        print(f"[{i}] {msg['role'].upper()} ({msg['timestamp']}):")
        print(msg['text'])
        print('-' * 80)

except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
