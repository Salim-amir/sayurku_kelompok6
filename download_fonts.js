const fs = require('fs');
const https = require('https');
const path = require('path');

const fonts = [
    { url: 'https://raw.githubusercontent.com/google/fonts/main/ofl/nunito/Nunito-Regular.ttf', name: 'Nunito-Regular.ttf' },
    { url: 'https://raw.githubusercontent.com/google/fonts/main/ofl/nunito/Nunito-Bold.ttf', name: 'Nunito-Bold.ttf' },
    { url: 'https://raw.githubusercontent.com/google/fonts/main/ofl/nunito/Nunito-ExtraBold.ttf', name: 'Nunito-ExtraBold.ttf' }
];

const dir = path.join(__dirname, 'assets', 'fonts');
if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
}

fonts.forEach(font => {
    const file = fs.createWriteStream(path.join(dir, font.name));
    https.get(font.url, response => {
        response.pipe(file);
        file.on('finish', () => {
            file.close();
            console.log(`Downloaded ${font.name}`);
        });
    }).on('error', err => {
        fs.unlink(font.name);
        console.error(`Error downloading ${font.name}: ${err.message}`);
    });
});
