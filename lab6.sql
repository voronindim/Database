-- 1 Добавить внешние ключи.
ALTER TABLE mark ADD
FOREIGN KEY(id_lesson) REFERENCES lesson(id_lesson)

ALTER TABLE mark ADD
FOREIGN KEY(id_student) REFERENCES student(id_student)

ALTER TABLE lesson ADD
FOREIGN KEY(id_teacher) REFERENCES teacher(id_teacher)

ALTER TABLE lesson ADD
FOREIGN KEY(id_subject) REFERENCES subject(id_subject)

ALTER TABLE lesson ADD
FOREIGN KEY(id_group) REFERENCES [group](id_group)

ALTER TABLE student ADD
FOREIGN KEY(id_group) REFERENCES [group](id_group)

-- 2 Выдать оценки студентов по информатике, если они обучаются данному предмету. Оформить выдачу данных с использованием view.

CREATE VIEW students_marks AS
SELECT student.name, mark.mark	
FROM mark
INNER JOIN lesson ON lesson.id_lesson = mark.id_lesson
INNER JOIN subject ON subject.id_subject = lesson.id_subject
INNER JOIN student ON mark.id_student = student.id_student
WHERE subject.name = N'информатика'
GO

SELECT * 
FROM students_marks


-- 3 Дать информацию о должниках с указанием фамилии студента и названия предмета. Должниками считаются студенты, не имеющие оценки по предмету, который ведется в группе. Оформить в виде процедуры, на входе идентификатор группы.

CREATE PROCEDURE get_debtor 
	@id_group AS INT
AS
	SELECT student.name, subject.name
	FROM student
	LEFT JOIN [group] ON [group].id_group = student.id_group
	LEFT JOIN lesson ON lesson.id_group = [group].id_group
	LEFT JOIN mark ON mark.id_lesson = lesson.id_lesson AND mark.id_student = student.id_student
	LEFT JOIN subject ON subject.id_subject = lesson.id_subject
	WHERE student.id_group = @id_group
	GROUP BY student.name, subject.name
	HAVING COUNT(mark.mark) = 0
GO

EXECUTE get_debtor @id_group = 1


-- 4 Дать среднюю оценку студентов по каждому предмету для тех предметов, по которым занимается не менее 35 студентов.
SELECT subject.name, AVG(mark.mark) AS average_mark
FROM mark
INNER JOIN lesson ON lesson.id_lesson = mark.id_lesson
INNER JOIN subject ON subject.id_subject = lesson.id_subject
INNER JOIN student ON mark.id_student = student.id_student
GROUP BY subject.name
HAVING COUNT(DISTINCT student.id_student) >= 35



-- 5 Дать оценки студентов специальности ВМ по всем проводимым предметам с указанием группы, фамилии, предмета, даты. 
--   При отсутствии оценки заполнить значениями NULL поля оценки.

SELECT student.name AS student_name, [group].name AS group_name, subject.name AS subject_name, lesson.date, mark.mark
FROM student
LEFT JOIN [group] ON [group].id_group = student.id_group
LEFT JOIN lesson ON lesson.id_group = [group].id_group
LEFT JOIN mark ON mark.id_lesson = lesson.id_lesson AND mark.id_student = student.id_student
LEFT JOIN subject ON subject.id_subject = lesson.id_subject
WHERE [group].name = N'ВМ'


-- 6 Всем студентам специальности ПС, получившим оценки меньшие 5 по предмету БД до 12.05, повысить эти оценки на 1 балл.

UPDATE mark
SET mark.mark = mark.mark + 1
FROM mark
INNER JOIN lesson ON lesson.id_lesson = mark.id_lesson
INNER JOIN [group] ON [group].id_group = lesson.id_group
INNER JOIN subject ON subject.id_subject = lesson.id_subject
WHERE 
	subject.name = N'БД' AND 
	mark.mark < 5 AND 
	lesson.date < N'2019-05-12' AND 
	[group].name = N'ПС'


-- 7 Добавить необходимые индексы.
CREATE NONCLUSTERED INDEX [IX_subject_name] ON subject  
(
	name ASC
)

CREATE NONCLUSTERED INDEX [IX_lesson_id_subject] ON lesson 
(
	id_subject ASC
)

CREATE NONCLUSTERED INDEX [IX_student_id_group-id_student] ON student
(
	id_group ASC,
	id_student ASC
)
INCLUDE(name)

CREATE NONCLUSTERED INDEX [IX_subject_id_subject] ON subject	
(
	id_subject ASC
)
INCLUDE(name)

CREATE NONCLUSTERED INDEX [IX_mark_id_lesson-id_student] ON mark	
(
	id_lesson ASC,
	id_student ASC
)
INCLUDE(mark)

CREATE NONCLUSTERED INDEX [IX_group_name-id_group] ON [group]	
(
	name ASC,
	id_group ASC
)

CREATE NONCLUSTERED INDEX [IX_lesson_id_group-id_subject] ON lesson	
(
	id_group ASC,
	id_subject ASC
)
INCLUDE(date)

CREATE NONCLUSTERED INDEX [IX_mark_id_lesson-mark] ON mark	
(
	id_lesson ASC,
	mark ASC
)

CREATE NONCLUSTERED INDEX [IX_subject_name-include_id_subject] ON subject	
(
	name ASC
)
INCLUDE(id_subject)