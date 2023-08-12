local app = {}

function app.start()
    --- Setup migrations
    require('app/model')
    require('app/func')

    --- Register app handlers
    rawset(_G, 'ad', require('app/ad'))
    rawset(_G, 'street', require('app/street'))
    rawset(_G, 'subscription', require('app/subscription'))
end

return app
