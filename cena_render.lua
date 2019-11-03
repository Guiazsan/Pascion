objeto = {x, y, r = 0, w = 10, h = 10, tipo, caminho, imagem, quad, texto}

function love.load()
    for i in ipairs(objeto) do
        if objeto[i].tipo == 'img' then
            objeto[i].imagem = love.graphics.newImage(objeto[i].caminho)
        end;
    end;   

end;

function Objeto:new ()
    objeto = objeto or {}
    setmetatable(objeto, self)
    self.__index = self
    return objeto
  end

function love.draw()
    for i in ipairs(objeto) do
        if objeto[i].tipo == 'img' then
            love.graphics.draw(
                objeto[i].imagem,
                objeto[i].x, 
                objeto[i].y, 
                objeto[i].r, 
                objeto[i].w/objeto[i].imagem:getWidth(), 
                objeto[i].h/objeto[i].imagem:getHeight())
        end;
        if (objeto[i].tipo == 'frect') or (objeto[i].tipo == 'lrect') then
            if objeto[i].tipo == 'frect' then modo = 'fill' else modo = 'line' end;
            love.graphics.rectangle(
                modo,
                objeto[i].x,
                objeto[i].y,
                objeto[i].w,
                objeto[i].h
            )
        end;
        if objeto[i].tipo == 'text' then
            love.graphics.print(
                objeto[i].texto,
                objeto[i].x,
                objeto[i].y,
                objeto[i].r
            )
        end;
    end;        
end;  
   