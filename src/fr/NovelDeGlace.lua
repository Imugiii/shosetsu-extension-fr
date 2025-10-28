-- {"id":10004,"ver":"1.0.0","libVer":"1.0.0","author":"Imugiii","repo":"https://github.com/Imugiii/shosetsu-extension-fr"}

--- Novel de Glace - Light Novels français (Isekai, Seinen)
local BASE_URL = "https://noveldeglace.com"

local settings = {
    name = "Novel de Glace",
    baseURL = BASE_URL,
    imageURL = "https://noveldeglace.com/favicon.ico",
    id = 10004,
    lang = "fr",
    isSearchIncrementing = true,
    chapterType = ChapterType.HTML
}

local function shrinkURL(url, type)
    if not url then return "" end
    url = url:gsub("^https?://[^/]*noveldeglace%.com", "")
    return url ~= "" and url or "/"
end

local function expandURL(url, type)
    return BASE_URL .. url
end

local function listings(data)
    local page = data[PAGE] or 1
    local url = BASE_URL
    if page > 1 then
        url = BASE_URL .. "/page/" .. page
    end
    
    local doc = GETDocument(url)
    local novels = {}
    
    local items = doc:select("article.post")
    
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local linkElement = item:selectFirst(".entry-title a")
        local imageElement = item:selectFirst(".post-thumbnail img")
        
        if linkElement then
            local novel = Novel()
            novel:setTitle(linkElement:text())
            novel:setLink(shrinkURL(linkElement:attr("href"), KEY_NOVEL_URL))
            
            if imageElement then
                local imgUrl = imageElement:attr("src")
                if imgUrl == "" then
                    imgUrl = imageElement:attr("data-src")
                end
                novel:setImageURL(imgUrl)
            end
            
            novels[#novels + 1] = novel
        end
    end
    
    return novels
end

local function search(data)
    local query = data[QUERY] or ""
    local url = BASE_URL .. "/?s=" .. query:gsub(" ", "+")
    
    local doc = GETDocument(url)
    local novels = {}
    
    local items = doc:select("article.post")
    
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local linkElement = item:selectFirst(".entry-title a")
        local imageElement = item:selectFirst(".post-thumbnail img")
        
        if linkElement then
            local novel = Novel()
            novel:setTitle(linkElement:text())
            novel:setLink(shrinkURL(linkElement:attr("href"), KEY_NOVEL_URL))
            
            if imageElement then
                local imgUrl = imageElement:attr("src")
                if imgUrl == "" then
                    imgUrl = imageElement:attr("data-src")
                end
                novel:setImageURL(imgUrl)
            end
            
            novels[#novels + 1] = novel
        end
    end
    
    return novels
end

local function parseNovel(novelURL, loadChapters)
    local url = expandURL(novelURL, KEY_NOVEL_URL)
    local doc = GETDocument(url)
    local novel = NovelInfo()
    
    local titleElement = doc:selectFirst("h1.entry-title")
    if titleElement then
        novel:setTitle(titleElement:text())
    end
    
    local imageElement = doc:selectFirst(".entry-content img")
    if imageElement then
        novel:setImageURL(imageElement:attr("src"))
    end
    
    local descElement = doc:selectFirst(".entry-content p")
    if descElement then
        novel:setDescription(descElement:text())
    end
    
    if loadChapters then
        local chapters = {}
        local linkElements = doc:select(".entry-content a")
        
        for i = 0, linkElements:size() - 1 do
            local link = linkElements:get(i)
            local text = link:text()
            
            if text:find("Chapitre") or text:find("Volume") or text:find("Prologue") or text:find("Tome") then
                local chapter = NovelChapter()
                chapter:setTitle(text)
                chapter:setLink(shrinkURL(link:attr("href"), KEY_CHAPTER_URL))
                chapter:setOrder(i)
                chapters[#chapters + 1] = chapter
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
    
    -- Essayer plusieurs sélecteurs possibles
    local contentElement = doc:selectFirst(".entry-content")
    if not contentElement then
        contentElement = doc:selectFirst(".post-content")
    end
    if not contentElement then
        contentElement = doc:selectFirst("article .entry-content")
    end
    if not contentElement then
        contentElement = doc:selectFirst("main .entry-content")
    end
    
    if contentElement then
        -- Nettoyer le contenu si nécessaire
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
        Listing("Romans", true, listings)
    },
    search = search,
    parseNovel = parseNovel,
    getPassage = getPassage,
    shrinkURL = shrinkURL,
    expandURL = expandURL
}
