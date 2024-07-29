for i=1,65,1 do
    turtle.digUp()
    turtle.up()
    turtle.turnLeft()
    turtle.dig()
    while not turtle.getItemDetail() or  turtle.getItemDetail()["name"] ~= "minecraft:polished_diorite" do
        turtle.select((turtle.getSelectedSlot()) % 16+1)
        sleep(0.1)
    end
    while not turtle.place() do
        -- turtle.placeDown()
        while not turtle.getItemDetail() or  turtle.getItemDetail()["name"] ~= "minecraft:polished_diorite" do
            turtle.select((turtle.getSelectedSlot()) % 16+1)
            sleep(0.1)
        end

    end
    turtle.turnRight()
    turtle.digDown()
    while not turtle.placeDown() do
        -- turtle.placeDown()
        while not turtle.getItemDetail() or  turtle.getItemDetail()["name"] ~= "minecraft:polished_diorite" do
            turtle.select((turtle.getSelectedSlot()) % 16+1)
            sleep(0.1)
        end
    end
    turtle.turnRight()
    turtle.dig()
    while not turtle.place() do
        -- turtle.placeDown()
        while not turtle.getItemDetail() or  turtle.getItemDetail()["name"] ~= "minecraft:polished_diorite" do
            turtle.select((turtle.getSelectedSlot()) % 16+1)
            sleep(0.1)
        end
    end
    turtle.turnLeft()
end