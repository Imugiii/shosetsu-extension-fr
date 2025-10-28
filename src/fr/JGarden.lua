-- {"id":10002,"ver":"1.0.0","libVer":"1.0.0","author":"Imugiii","repo":"https://github.com/Imugiii/shosetsu-extension-fr"}

--- J-Garden - Traductions de Light Novels japonais
local BASE_URL = "https://j-garden.fr"

local settings = {
    name = "J-Garden",
    baseURL = BASE_URL,
    imageURL = "https://j-garden.fr/wp-content/uploads/2021/01/cropped-logo-jg-32x32.png",
    id = 10002,
    lang = "fr",
    isSearchIncrementing = true,
    chapterType = ChapterType.HTML
}

local function shrinkURL(url, type)
    if not url then return "" end
    url = url:gsub("^https?://[^/]*j%-garden%.fr", "")
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
        local imageElement = item:selectFirst(".entry-image img")
        
        if linkElement then
            local novel = Novel()
            novel:setTitle(linkElement:text())
            novel:setLink(shrinkURL(linkElement:attr("href"), KEY_NOVEL_URL))
            
            if imageElement then
                novel:setImageURL(imageElement:attr("src"))
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
        local imageElement = item:selectFirst(".entry-image img")
        
        if linkElement then
            local novel = Novel()
            novel:setTitle(linkElement:text())
            novel:setLink(shrinkURL(linkElement:attr("href"), KEY_NOVEL_URL))
            
            if imageElement then
                novel:setImageURL(imageElement:attr("src"))
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
    
    local descElement = doc:selectFirst(".entry-content")
    if descElement then
        novel:setDescription(descElement:text())
    end
    
    if loadChapters then
        local chapters = {}
        local linkElements = doc:select(".entry-content a")
        
        for i = 0, linkElements:size() - 1 do
            local link = linkElements:get(i)
            local text = link:text()
            
            if text:find("Chapitre") or text:find("Volume") or text:find("Prologue") or text:find("Épilogue") then
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
    local contentElement = doc:selectFirst(".entry-content")
    
    if contentElement then
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
