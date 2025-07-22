const fs = require('fs')
const yaml = require('yaml')
const Handlebars = require('handlebars')

const modelFile = fs.readFileSync('./models.yaml', 'utf8')
const modelsFile = yaml.parse(modelFile)
const models = modelsFile.models

Handlebars.registerHelper('import', function(checkId, path) {
    return `import check${checkId.replace(/\./g, "")} from "!!raw-loader!../../../../macros/${path}";`
})

Handlebars.registerHelper('checkId', function(checkId) {
    return checkId.replace(/\./g, "")
})

let template = Handlebars.compile(fs.readFileSync('./templates/default-model.hbs', 'utf8'))

dirPath = './docs/models/'
// Create the models directory
if (fs.existsSync(dirPath)) {
    fs.rmSync(dirPath, { recursive: true, force: true })
}

fs.mkdirSync(dirPath, { recursive: true })

for (let key in models) {
    let model = models[key]

    let modelPath = dirPath + model.name.toLowerCase()
    if (!fs.existsSync(modelPath)) {
        fs.mkdirSync(modelPath, { recursive: true })
    }

    fs.writeFileSync(modelPath + '/_category_.json', JSON.stringify({
        "label": model.name,
        "position": parseInt(key, 10) + 1,
        "link": {
            "type": "generated-index",
            "description": model.description
        }
    }, null, 2))

    let controls = model.controls || []

    for (let controlIdx in controls) {
        let control = controls[controlIdx]

        let controlPath = modelPath + '/' + control.name.toLowerCase() + '.mdx'

        fs.writeFileSync(controlPath, template({
            index: controlIdx,
            title: control.name,
            description: control.description,
            checks: control.checks || []
        }))
    }
}

