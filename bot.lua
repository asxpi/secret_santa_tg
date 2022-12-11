local api = require('telegram-bot-lua.core').configure('5842622732:AAGlom1wBdphCYrIq_uKCyn7eoahmZR3v5s')
local inspect = require 'inspect'
local jsonstorage = require 'jsonstorage'

local firstTime = true
local members = { } 

local function save()
    jsonstorage.saveTable(members, 'db.json')
end

local function load()
    members = jsonstorage.loadTable('db.json')    
end

function api.on_message(message)
    --print(inspect(message))

    if firstTime then
        firstTime = false
        load()
    else 
        save()
    end

    local arrayid = '#'..message.chat.id

    if message.text and message.text:match('/start') then
        api.send_message(
            message.chat.id,
            'Добро пожаловать, ' .. message.chat.first_name .. '. Снова.\n'
            ..'Ты кстати знал что твой телеграм ид ' .. message.chat.id .. '?\n'
            ..'Это бот для секретного санты Эстача, он написан мной на коленке и полностью командный.'
        )
        api.send_message(
            message.chat.id,
            '/register - регистарция\n'.. 
            '/like чтобы вы хотели получить\n'.. 
            '/dislike чтобы вы не хотели получить\n'..
            '/roll - доступна только админам и по выдает всем участникам человека которому они должны что-то подарить'
        )
    end

    if message.text and message.text:match('/register') then
        api.send_message(
            message.chat.id,
            'Ты успешно зарегестрирован, твоему секретному санте будет передан твой текущий ник и телеграм ид. \n'
        )
        members[arrayid] = {
            username = message.chat.username,
            like = '',
            dislike = '',
            chatid = message.chat.id
        }
    end

    if message.text and message.text:match('/like') then
        if(type(members[arrayid]) == 'nil') then
            api.send_message(
                message.chat.id,
                'Сначало зарегистрируйся \n/register'
            )
        else
        api.send_message(
            message.chat.id,
            'Твои пожелания добавлены. \n'
        )
        members[arrayid].like = message.text:gsub("%/like ", "")
        end
    end

    if message.text and message.text:match('/dislike') then
        if(type(members[arrayid]) == 'nil') then
            api.send_message(
                message.chat.id,
                'Сначало зарегистрируйся \n/register'
            )
        else
        api.send_message(
            message.chat.id,
            'Твои пожелания добавлены. \n'
        )
        members[arrayid].dislike = message.text:gsub("%/dislike ", "")
        end
    end

    if message.text and message.text:match('/roll') then
        if message.chat.id == 298559527 then
            api.send_message(
            message.chat.id,
            'Ебашим \n'      
        )
        print(inspect(members))
        else
            api.send_message(
            message.chat.id,
            'Ты не @asxpi, сходи нахуй.'      
        )
        end
    end

    if message.text and message.text:match('/save') then
        save()
        api.send_message(
            message.chat.id,
            'Схоронили.'   
        )
    end

    if message.text and message.text:match('/load') then
        load()
        api.send_message(
            message.chat.id,
            'Загрузили.'   
        )
    end
end

api.run()