
AddCSLuaFile()

local invadedMessages = {
    -- AdVerTiozeMents
    { "Supercop has arrived.", "He just ended a 1 hour Hunter's Glee round..." },
    { "Supercop is here.", "He just spent 3 hours on a 35 player sandbox server..." },
    { "Supercop has arrived.", "He just left a 32 player TTT session..." },
    { "Supercop has arrived.", "He just killed everyone in a 10 minute TTT session..." },
    { "Supercop has arrived.", "Terrorism just got... Terrifying!" },
    { "Supercop has arrived.", "Terrorism is a felony..." },
    { "Supercop has arrived.", "Terrorism gets the death penalty..." },

    -- random
    { "Supercop has logged in.", "His hair is like a horse's mane!" },
    { "Supercop has arrived.", "The date? 5th of June, 1989..." },
    { "Supercop was dropped off by their parents! They have a great relationship!" },
    { "Supercop has invaded,", "jaywalkers BEware..." },
    { "Supercop has invaded....", "Shouldn't have downloaded that car..." },
    { "Supercop is on duty.", "It's not illegal if he doesn't catch you..." },
    { "Supercop has invaded.", "Should've stuck to the speed limit..." },
    { "Supercop has invaded.", "Remember folks, unlicensed fall damage is a crime..." },
    { "Supercop has invaded.", "Propsurf won't save you..." },
    { "Supercop has invaded.", "Get to the models/props_phx/misc/bunker01.mdl!!" },
    { "Supercop has invaded", "Should've kept your dupes up to spec..." },
    { "Supercop has invaded.", "Why? Too many watermelons..." },
    { "Supercop's lua has started.", "Problem is, you're overflowing his stack." },
    { "Supercop is on duty.", "'Friendly fire' just became a 'friendly' felony..." },
    { "Supercop has invaded.", "Get to to the bathtub car!!!" },
    { "Supercop has invaded.", "He's friendly!" },
    { "Supercop has arrived,", "hope your contraptions don't violate any health and safety codes..." },
    { "Supercop has invaded.", "Hope your builds are up to OSHA standards..." },
    { "Supercop has logged in...", "who needs ULX when you have bullets?" },
    { "Supercop has invaded.", "He's always behind you..." },
    { "Supercop has arrived.", "No insurance on your flying bathtub? That's a ticket..." },
    { "Supercop has invaded.", "Beware: He knows you stole your Garry NFTs..." },
    { "Supercop has invaded.", "Beware: He knows where you've hidden your stash of garry NFTS..." },
    { "Supercop has invaded.", "Beware: GMAN ratted out your NFTS of garry's luscious locks..." },
    { "Supercop is on duty.", "Your prop block won't do you much good now..." },
    { "Supercop has invaded.", "Shouldn't have cheated those achievements in..." },
    { "Supercop's in the server.", "Your very... classy \"spaceship\" probably got the attention of the neighbors..." },
    { "Supercop has invaded.", "Better bolt your doors, pray your props aren't breakable..." },
    { "Supercop is online.", "Best hope your contraption can outrun the law..." },
    { "Supercop has entered.", "Tricks are nice, but can't trick a bullet..." },
    { "Supercop is in pursuit.", "His bodycam is off..." },
    { "Supercop is in pursuit.", "His bodycam is \"out of battery\"..." },
    { "Supercop's invading,", "He knows..." },
    { "Supercop's invading,", "He knows where you sleep..." },
    { "Supercop has arrived.", "Don't shoot!" },

    -- rdm jokes
    { "Supercop has landed.", "Familiar with the term 'RDM', right?" },
    { "Supercop has invaded.", "Random death match? More like death penalty..." },
    { "Supercop has invaded, and", "He's going to fight RDM with RDM..." },
    { "Supercop is laying down the law.", "Propsurf gets the Death penalty." },
    { "Supercop has rolled up. And", "he doesn't care about \"R D M\"." },
    { "Supercop's invading,", "Deathmatch is gonna get alot less random..." },

    -- server rules/admin meta jokes
    { "Supercop has invaded.", "Should've read each of the 42 rules..." },
    { "Supercop has invaded.", "According to rule 38, subrule 12, you fucked up..." },
    { "Supercop has invaded.", "According to rule 21, subrule 5, you're a criminal..." },
    { "Supercop's invading,", "Better beg the admins to remove him..." },
    { "Supercop's invading, And", "he doesn't read the rules..." },
    { "Supercop's invading,", "He's a professional rule lawyer..." },
    { "Supercop's invading,", "He knows you've been proppushing..." },
    { "Supercop has invaded.", "He wants to apply for admin!" },
    { "Supercop has invaded.", "He's stepping down from admin..." },
    { "Supercop has invaded.", "He'll take over the server at this rate!" },
    { "Supercop has invaded.", "He'll always have a backdoor into our hearts!" },
    { "Supercop has invaded.", "Rules don't apply to justice!" },
    { "Supercop has invaded.", "Admin abuse won't save you now!" },
    { "Supercop has invaded.", "His secret weapon? He read the rules..." },
    { "Supercop has invaded.", "His secret weapon? He never breaks a rule..." },
    { "Supercop has invaded.", "His secret weapon? He paid the admins for VIP..." },
    { "Supercop has invaded.", "His secret weapon? He slipped the admins a crisp 20..." },

    -- secret weapon
    { "Supercop has invaded.", "His secret weapon? Enlightenment..." },
    { "Supercop has invaded.", "His secret weapon? Lifting..." },
    { "Supercop has invaded.", "His secret weapon? Exercise..." },
    { "Supercop has invaded.", "His secret weapon? Nature..." },
    { "Supercop has invaded.", "His secret weapon? Jesus..." },
    { "Supercop has invaded.", "His secret weapon? Buddha..." },
    { "Supercop has invaded.", "His secret weapon? Justice..." },
    { "Supercop has invaded.", "His secret weapon? Allah..." },

    -- referencing citizen quotes
    { "Supercop has invaded.", "He's got a good feeling about this..." },
    { "Supercop has invaded.", "Shouldn't have dreamed about cheese..." },
    { "Supercop has invaded.", "He's talkin to you..." },
    { "Supercop has invaded. And", "about time, too..." },
    { "Supercop has invaded.", "He just wanted to sell insurance..." },
    { "Supercop has invaded.", "He's gonna make a stalker out of you..." },
    { "Supercop has invaded.", "It's just one of those days..." },
    { "Supercop has invaded.", "This is bad..." },
    { "Supercop has invaded.", "What now?" },
    { "Supercop has invaded.", "Try not to dwell on it..." },
    { "Supercop has invaded.", "He'll put it on your tombstone..." },
    { "Supercop has invaded.", "There's a first time for everything..." },
    { "Supercop has invaded.", "He's not one to even the odds..." },
    { "Supercop has invaded...", "Finally!" },
    { "Supercop has invaded.", "Get down!" },
    { "Supercop has invaded!", "Get, the hell out of here!" },
    { "Good god... Not Supercop!!" },
    { "Supercop has invaded!", "Spread the word..." },
    { "We're done for... Supercop!" },
    { "Supercop has invaded!", "What a way to go..." },
    { "Supercop has invaded!", "Don't take it personally..." },
    -- kliener quotes
    { "Supercop has invaded!", "Where did he get to!" },
    { "Supercop has invaded!", "It'll be an hour before you coax him out!" },
    { "Dear me... Supercop!" },
    { "Oh fiddlesticks... Supercop!" },
    { "There seems to be some kind of interference... Supercop!" },
    { "Supercop has invaded!", "And at such an inopportune time!" },
    { "Supercop has invaded!", "Shouldn't have teleported that cat!" },
    -- g guy
    { "Rise and shine, supercop, rise, and shine..." },
    { "The right supercop, in the wrong map, can create all the diff-erence, in the world..." },

    -- food
    { "Supercop is in pursuit.", "Cold, hard justice is his beverage of choice..." },
    { "Supercop has invaded.", "His coffee was great this morning!" },
    { "Supercop has invaded.", "His coffee tasted like mine tailings..." },
    { "Supercop has invaded.", "His coffee tasted like headcrab...?" },
    { "Supercop has invaded.", "His coffee tasted like vortigaunt!" },
    { "Supercop has invaded.", "His coffee reminded him of his childhood!" },
    { "Supercop has invaded.", "His coffee reminded him of his... adulthood?" },
    { "Supercop has invaded.", "His coffee is single origin!" },
    { "Supercop has invaded.", "His coffee pairs great with doughnuts!" },
    { "Supercop has invaded.", "His coffee tasted like iron..." },
    { "Supercop has invaded.", "His coffee was decaf..." },
    { "Supercop has invaded.", "His coffee creamer was spoiled..." },
    { "Supercop has invaded.", "They got his coffee wrong..." },
    { "Supercop has invaded.", "Someone tried to make him tea..." },
    { "Supercop has invaded.", "His favourite donuts are chocolate spinkle!" },
    { "Supercop has invaded.", "You better hope he didn't miss the last doughnut..." },
    { "Supercop has invaded.", "A headcrab cannister was just dropped on his lunch..." },
    { "Supercop has invaded.", "He left his lunch in the dropship..." },
    { "Supercop has invaded.", "A strider stepped on his lunch..." },
    { "Supercop has invaded.", "A headcrab ate his lunch..." },
    { "Supercop has invaded.", "He's a vegan!" },
    { "Supercop has invaded.", "He's on a diet..." },

    -- cities
    { "Supercop has invaded.", "He just transferred from portland..." },
    { "Supercop has invaded.", "He just transferred from cleaveland..." },
    { "Supercop has invaded.", "He just transferred from new york..." },
    { "Supercop has invaded.", "He just transferred from detroit..." },
    { "Supercop has invaded.", "He just transferred from miami... oklahoma..." },
    { "Supercop has invaded.", "He just transferred from LA..." },
    { "Supercop has invaded.", "He just transferred from san francisco..." },
    { "Supercop has invaded.", "He just transferred from vancouver..." },
    { "Supercop has invaded.", "He just transferred from vancouver... washington..." },
    { "Supercop has invaded.", "He just transferred from moscow..." },
    -- name
    { "Supercop's invading,", "His middle name? Justice." },
    { "Supercop's invading,", "His middle name? Law." },
    { "Supercop's invading,", "His middle name? Order." },
    { "Supercop's invading,", "His middle name? Dion." },
    { "Supercop's invading,", "His first name? Ron." },
    { "Supercop's invading,", "His initials? LAW." },
    -- tutorials
    { "Supercop has invaded.", "GET TO THE ELEVATORS!" },
    { "Supercop has invaded.", "Better pray this map has teleporters!" },
    { "Supercop has invaded.", "Better pray the ladders aren't navmeshed!" },
    { "Supercop has invaded.", "Better pray this navmesh is unpolished..." },
    { "Supercop is on deck.", "Your tool gun won't change the law..." },
    { "Supercop is on deck.", "Your toolgun isn't strong enough..." },
    { "Supercop is in the map.", "Should've updated your toolgun drivers..." },
    { "Supercop is on duty.", "Sorry, your toolgun must be version 25 or higher to remove him!" },
    { "Supercop is here.", "You can't ai_disable the law..." },
    { "Supercop's invading!", "ai_ignoreplayers? Justice doesn't ignore..." },
    { "Supercop's invaded!", "ai_ignoreplayers? Why would the LAW ignore a criminal!" },
    { "Supercop has entered the server.", "Justice always beats the physics gun..." },
    { "Supercop has invaded.", "Please insert card to upgrade your physics gun to version 25!" },
    { "Supercop has invaded.", "Sorry, your physics gun is on the free plan..." },

}

local invadedMessagesToPrint = {}

function supercopNextbot_SupercopInvadedMessageTbl()
    if #invadedMessagesToPrint <= 1 then
        invadedMessagesToPrint = table.Copy( invadedMessages )

    end

    return table.remove( invadedMessagesToPrint, math.random( 1, #invadedMessagesToPrint ) )

end

function supercopNextbot_SupercopInvadedMessage()
    local tbl = supercopNextbot_SupercopInvadedMessageTbl()
    message = table.concat( tbl, " " )

    return message

end