# == Schema Information
#
# Table name: countries
#
#  name        :string       not null, primary key
#  continent   :string
#  area        :integer
#  population  :integer
#  gdp         :integer

require_relative './sqlzoo.rb'

# BONUS QUESTIONS: These problems require knowledge of aggregate
# functions. Attempt them after completing section 05.

def highest_gdp
  # Which countries have a GDP greater than every country in Europe? (Give the
  # name only. Some countries may have NULL gdp values)
  execute(<<-SQL)
    SELECT
      name
    FROM
      countries
    WHERE
      gdp > (
            SELECT
              MAX(gdp)
            FROM
              countries
            WHERE
              continent = 'Europe'
            )
  SQL
end

def largest_in_continent
  # Find the largest country (by area) in each continent. Show the continent,
  # name, and area.
  execute(<<-SQL)
    SELECT
      c2.continent, c1.name, c2.area
    FROM
      countries AS c1
    INNER JOIN (SELECT
                  continent, MAX(area) AS area
                FROM
                  countries
                GROUP BY continent) AS c2
    ON c1.continent = c2.continent AND c1.area = c2.area
  SQL
end

def large_neighbors
  # Some countries have populations more than three times that of any of their
  # neighbors (in the same continent). Give the countries and continents.
  execute(<<-SQL)
    SELECT
      c3.name, c3.continent
    FROM (SELECT c1.continent, c1.population
          FROM countries AS c1
          INNER JOIN countries AS c2
          ON c1.continent = c2.continent AND c1.name <> c2.name
          GROUP BY c1.continent, c1.population
          HAVING MAX(c1.population) > 3*MAX(c2.population)) AS cmax
    INNER JOIN countries AS c3
    ON cmax.continent = c3.continent AND cmax.population = c3.population
  SQL
end
