for _, color in ipairs({
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "a",
    "b",
    "c",
    "d",
    "e",
    "f"
}) do
    print(color .. " is " .. "\011f" .. color .. "this\011f0")
end