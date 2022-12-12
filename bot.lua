--local api = require('telegram-bot-lua.core').configure('')
local api = require('telegram-bot-lua.core').configure('')
local inspect = require 'inspect'
local jsonstorage = require 'jsonstorage'

local adminid = adminid
local firstTime = true
local db = { } 

local function save()
    jsonstorage.saveTable(db, 'db.json')
end

local function load()
    db = jsonstorage.loadTable('db.json')    
end

function api.on_message(message)
    --print(inspect(message))

    if firstTime then
        firstTime = false
        load()
    else
        save()
    end

    --if db.status == nil then 
        --db.status = 0
    --end

    local arrayid = '#'..message.chat.id

    if message.text and message.text:match('/start') then
        api.send_message(
            message.chat.id,
            'Добро пожаловать, ' .. message.chat.first_name .. '. Снова.\n'
            ..'Ты кстати знал что твой телеграм ид ' .. message.chat.id .. '?\n'
            ..'Это бот для секретного санты Эстача, он написан мной на коленке под оксикодоном.\n'
        )
        api.send_message(
            message.chat.id,
            '/register - регистарция\n'.. 
            '/deleteme - удалить свой аккаунт, возможно только до начала игры\n'..
            '/like 20кг кокаина, лыжи, поебалу\n'.. 
            '/dislike наркотиков, пони, бонг\n'..
            '/me - как будет выглядеть твой профиль для секретного санты.'
        )
    end

    if message.text and message.text:match('/register') then
        api.send_message(
            message.chat.id,
            'Ты успешно зарегестрирован, твоему секретному санте будет передан твой текущий ник и телеграм ид. \n'
        )
        db[arrayid] = {
            username = message.chat.username,
            like = '',
            dislike = '',
            chatid = message.chat.id
        }
    end

    if message.text and message.text:match('/deleteme') then
        if(type(db[arrayid]) == 'nil') then
            api.send_message(
                message.chat.id,
                'Ты не зарегестрирован'
            )
        else
        db[arrayid] = nil
        api.send_message(
            message.chat.id,
            'Твои данные удалены \n'
        )
        end
    end

    if message.text and message.text:match('/like') then
        if(type(db[arrayid]) == 'nil') then
            api.send_message(
                message.chat.id,
                'Сначало зарегистрируйся \n/register'
            )
        else
        api.send_message(
            message.chat.id,
            'Твои пожелания добавлены. \n'
        )
        db[arrayid].like = message.text:gsub("%/like ", "")
        end
    end

    if message.text and message.text:match('/dislike') then
        if(type(db[arrayid]) == 'nil') then
            api.send_message(
                message.chat.id,
                'Сначало зарегистрируйся \n/register'
            )
        else
        api.send_message(
            message.chat.id,
            'Твои пожелания добавлены. \n'
        )
        db[arrayid].dislike = message.text:gsub("%/dislike ", "")
        end
    end

    if message.text and message.text:match('/roll') then
        if message.chat.id == adminid then
            api.send_message(
            message.chat.id,
            'Ебашим \n'      
        )
        --db.status = 1
        local keyset = {}
        local n = 0

        for k, v in pairs(db) do
            n=n+1
            keyset[n] = v.chatid
        end

        for k, v in pairs(db) do
            print(#keyset)
            local key = math.random(#keyset)
            local sendTo = keyset[key]
            while sendTo == v.chatid do
                key = math.random(#keyset)
                sendTo = keyset[key]
                print('While loop cause sender == recipient')
            end
            -- Who will send me?
            local recipient = '#'..sendTo --
            db[recipient].senderId = v.chatid
            db[recipient].senderUsername = v.username
            v.sendTo = db[recipient].username
            v.sendToId = db[recipient].chatid
            table.remove(keyset, key)
            --keyset[rnd] = nil
        end
        
        for k, v in pairs(db) do
            local target = '#'.. v.sendToId
            api.send_message(
            v.chatid,
            'Привет. Секретный санта начался.\n'
            ..'Твоя цель:@'..v.sendTo..' или Telegram ID:'..v.sendToId..' , если эта мразь сменила ник в телеге.\n'
            ..'Твоя цель любит: ' .. db[target].like .. '\n'
            ..'Твоя цель не любит: ' .. db[target].dislike ..'\n'
            ..'После окончания игры мы раскажем кто был твоим Секретным Сантой'
        )
        end

        else
            api.send_message(
            message.chat.id,
            'Ты не @asxpi, сходи нахуй.'      
        )
        end
    end

    if message.text and message.text:match('/save') then
        if message.chat.id == adminid then
            save()
            api.send_message(
                message.chat.id,
                'Сохронили.'   
            )
        else
            api.send_message(
            message.chat.id,
            'Ты не @asxpi, сходи нахуй.'      
        )
        end
    end

    if message.text and message.text:match('/load') then
        if message.chat.id == adminid then
            load()
            api.send_message(
                message.chat.id,
                'Загрузили.'   
            )
        else
            api.send_message(
            message.chat.id,
            'Ты не @asxpi, сходи нахуй.'      
        )
        end
    end

    if message.text and message.text:match('/inspect') then
        if message.chat.id == adminid then
            local text = inspect(db)
            api.send_message(
                message.chat.id,
                text   
            )
        else
            api.send_message(
            message.chat.id,
            'Ты не @asxpi, сходи нахуй.'      
        )
        end
    end

    if message.text and message.text:match('/me') then
        local text = 'Привет. Секретный санта начался.\n'
        ..'Твоя цель:@'..message.chat.username..' или Telegram ID:'..message.chat.id..' , если эта мразь сменила ник в телеге.\n'
        ..'Твоя цель любит: ' .. db[arrayid].like .. '\n'
        ..'Твоя цель не любит: ' .. db[arrayid].dislike ..'\n'
        ..'После окончания игры мы раскажем кто был твоим Секретным Сантой'

        api.send_message(
            message.chat.id,
            text     
        )
    end

    if message.text and message.text:match('/end') then
        if message.chat.id == adminid then
            for k, v in pairs(db) do
                local target = '#'.. v.sendToId
                api.send_message(
                v.chatid,
                'Привет. Секретный Cанта закончился.\nЯ надеюсь ты уже подарил свой подарок, если нет то ты мразь. \n'
                .. 'Тебе должен был подарить подарок: @'..v.senderUsername.. ' Или Tg ID:' .. v.senderId .. '\n'
                .. 'Всем спасибо за игру.'
            )
            end
        else
            api.send_message(
            message.chat.id,
            'Ты не @asxpi, сходи нахуй.'      
        )
        end
    end
end

api.run()
