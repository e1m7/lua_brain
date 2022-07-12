
--[[

	1) colors = библиотека для вывода цветных сообщений
	2) code = исходный код на Brainfuck (желательно, верный)
	3) pointer = указатель на символ, который выполняется
	5) brackets = таблица скобок внутри кода {10:5, 5:10}
	6) cells = таблица ячеек, в которых будут находится данные
	7) index = указатель на ячейку, с которой сейчас работаем
	8) вспомогательная переменная а = для посчета скобок
	9) вспомогательная таблица b = для временного хранения скобок

]]

local colors = require 'ansicolors'

local code = '>++++++++[<+++++++++>-]<.>++++[<+++++++>-]<+.+++++++..+++.>>++++++[<+++++++>-]<++.------------.>++++++[<+++++++++>-]<+.<.+++.------.--------.>>>++++[<++++++++>-]<+.'
-- local code = '+++++++++++++[>++>+++++<<-]>[>.+<-]'

local pointer = 1
local brackets = {}
local cells = {}
local index = 1

local a = 0
local b = {}

--[[

	1) формирование таблицы скобок, которые запсиываются попарно
	2) проходим по всему коду (строке) и выдергиваем очередной символ
	3) если символ == [, то добавляем в таблицу i и a=a+1
	4) если символ == ], то формируем пару записей
			а) текущий индекс (]) : ранее сохраненный индекс ([)
			б) ранее сохраненный индекс ([) : текущий индекс (])
	5) удаляем а и b (ибо надо экономить память)

]]

for i = 1, code:len() do
	local c = code:sub(i,i)
  if c == '[' then
  	table.insert(b,i)
  	a = a + 1
  end
  if c == ']' then
  	brackets[i] = b[a]
  	brackets[b[a]] = i
  	b[a] = nil
  	a = a - 1
  end
end

a = nil
b = nil

--[[

	1) выполняем очередной шаг в строке кода
	2) если +, то в текущую ячейку +1
	3) если -, то в текущую ячейку -1
	4) если >, то увеличиваем index (идем справо)
	5) если <, то уменьшаем index (идем влево)
	6) если [ и в текущей ячейке 0, то прыжок brackets[pointer]
	7) если ] и в текущей ячейке не 0, то прыжок brackets[pointer]
	8) если ., то выводим зеленым цветом символ с кодом из текущей ячейки
	9) если ,, то считываем символ и его код кладем в текущую ячейку

]]

function nextInstr(instr)
	if instr == '+' then
		cells[index] = (cells[index] or 0) + 1
	elseif instr == '-' then
		cells[index] = (cells[index] or 0) - 1
	elseif instr == '>' then
		index = index + 1
	elseif instr == '<' then
		index = index - 1
	elseif instr == '[' then
		if cells[index] == 0 then
			pointer = brackets[pointer]
		end
	elseif instr == ']' then
		if cells[index] ~= 0 then
			pointer = brackets[pointer]
		end
	elseif instr == '.' then
		io.write(colors('%{greenbg}'..string.char(cells[index] or 0)..'%{reset}'))
	elseif instr == ',' then
		cells[index] = tonumber(string.byte(io.read()))
	end
end

--[[

	1) крутим цикл от 1 до длины строки кода
	2) вызываем функцию обработки кода дял текущего символа
	3) накидываем счетчик команд, чтобы пройти по всей строке

]]

while pointer <= #code do
	nextInstr(code:sub(pointer, pointer))
	pointer = pointer + 1
end

print()