-- {"id":10003,"ver":"1.0.0","libVer":"1.0.0","author":"Imugiii","repo":"https://github.com/Imugiii/shosetsu-extension-fr"}

--- Baka-Tsuki FR - Light Novels traduits en français
local BASE_URL = "https://www.baka-tsuki.org"

local settings = {
    name = "Baka-Tsuki FR",
    baseURL = BASE_URL,
    imageURL = "https://www.baka-tsuki.org/project/logo.png",
    id = 10003,
    lang = "fr",
    isSearchIncrementing = true,
    chapterType = ChapterType.HTML
}

local function shrinkURL(url, type)
    return url:gsub("^.-baka%-tsuki%.org", "")
end

local function expandURL(url, type)
    if url:sub(1, 1) == "/" then
        return BASE_URL .. url
    elseif url:find("^https?://") then
        return url
    else
        return BASE_URL .. "/project/index.php" .. url
    end
end

local function listings(data)
    local url = BASE_URL .. "/project/index.php?title=Catégorie:Français"
    
    local doc = GETDocument(url)
    local novels = {}
    
    local items = doc:select("#mw-pages .mw-content-ltr li a")
    
    for i = 0, items:size() - 1 do
        local link = items:get(i)
        local title = link:text()
        local href = link:attr("href")
        
        local novel = Novel()
        novel:setTitle(title)
        novel:setLink(shrinkURL(href, KEY_NOVEL_URL))
        novels[#novels + 1] = novel
    end
    
    return novels
end

local function search(data)
    local query = data[QUERY] or ""
    local url = BASE_URL .. "/project/index.php?title=Catégorie:Français"
    
    local doc = GETDocument(url)
    local novels = {}
    
    local items = doc:select("#mw-pages .mw-content-ltr li a")
    
    for i = 0, items:size() - 1 do
        local link = items:get(i)
        local title = link:text()
        
        if query == "" or title:lower():find(query:lower()) then
            local href = link:attr("href")
            local novel = Novel()
            novel:setTitle(title)
            novel:setLink(shrinkURL(href, KEY_NOVEL_URL))
            novels[#novels + 1] = novel
        end
    end
    
    return novels
end

local function parseNovel(novelURL, loadChapters)
    local url = expandURL(novelURL, KEY_NOVEL_URL)
    local doc = GETDocument(url)
    local novel = NovelInfo()
    
    local titleElement = doc:selectFirst("#firstHeading")
    if titleElement then
        local title = titleElement:text():gsub(" ~ Français", "")
        novel:setTitle(title)
    end
    
    local imageElement = doc:selectFirst(".infobox img")
    if imageElement then
        local imgSrc = imageElement:attr("src")
        if imgSrc:sub(1, 2) == "//" then
            novel:setImageURL("https:" .. imgSrc)
        elseif imgSrc:sub(1, 1) == "/" then
            novel:setImageURL("https:" .. imgSrc)
        elseif not imgSrc:find("^https?://") then
            novel:setImageURL(BASE_URL .. imgSrc)
        else
            novel:setImageURL(imgSrc)
        end
    end
    
    if loadChapters then
        local chapters = {}
        local volumeElements = doc:select("h2, h3")
        
        for i = 0, volumeElements:size() - 1 do
            local heading = volumeElements:get(i)
            local nextSibling = heading:nextElementSibling()
            
            if nextSibling and nextSibling:tagName() == "ul" then
                local links = nextSibling:select("li a")
                
                for j = 0, links:size() - 1 do
                    local link = links:get(j)
                    local href = link:attr("href")
                    local chapter = NovelChapter()
                    chapter:setTitle(link:text())
                    chapter:setLink(shrinkURL(href, KEY_CHAPTER_URL))
                    chapter:setOrder(#chapters)
                    chapters[#chapters + 1] = chapter
                end
            end
        end
        
        novel:setChapters(chapters)
    end
    
    novel:setStatus(NovelStatus.PUBLISHING)
    return novel
end

local function getPassage(chapterURL)
    local url = expandURL(chapterURL, KEY_CHAPTER_URL)
    local doc = GETDocument(url)
    local contentElement = doc:selectFirst("#mw-content-text")
    
    if contentElement then
        local navElements = contentElement:select(".toc, .navbox")
        for i = 0, navElements:size() - 1 do
            navElements:get(i):remove()
        end
        
        return contentElement:html()
    end
    
    return ""
end

return {
    id = settings.id,
    name = settings.name,
    baseURL = settings.baseURL,
    imageURL = settings.imageURL,
    lang = settings.lang,
    isSearchIncrementing = settings.isSearchIncrementing,
    chapterType = settings.chapterType,
    listings = {
        Listing("Romans FR", false, listings)
    },
    search = search,
    parseNovel = parseNovel,
    getPassage = getPassage,
    shrinkURL = shrinkURL,
    expandURL = expandURL
}
