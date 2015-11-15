# == Schema Information
#
# Table name: stops
#
#  id          :integer      not null, primary key
#  name        :string
#
# Table name: routes
#
#  num         :string       not null, primary key
#  company     :string       not null, primary key
#  pos         :integer      not null, primary key
#  stop_id     :integer

require_relative './sqlzoo.rb'

def num_stops
  # How many stops are in the database?
  execute(<<-SQL)
    SELECT
      COUNT(id)
    FROM
      stops
  SQL
end

def craiglockhart_id
  # Find the id value for the stop 'Craiglockhart'.
  execute(<<-SQL)
    SELECT
      id
    FROM
      stops
    WHERE
      name = 'Craiglockhart'
  SQL
end

def lrt_stops
  # Give the id and the name for the stops on the '4' 'LRT' service.
  execute(<<-SQL)
    SELECT
      s.id, s.name
    FROM stops AS s
    INNER JOIN routes AS r
    ON s.id = r.stop_id
    WHERE
      r.num = '4'
      AND
      r.company = 'LRT'
  SQL
end

def connecting_routes
  # Consider the following query:
  #
  # SELECT
  #   company,
  #   num,
  #   COUNT(*)
  # FROM
  #   routes
  # WHERE
  #   stop_id = 149 OR stop_id = 53
  # GROUP BY
  #   company, num
  #
  # The query gives the number of routes that visit either London Road
  # (149) or Craiglockhart (53). Run the query and notice the two services
  # that link these stops have a count of 2. Add a HAVING clause to restrict
  # the output to these two routes.
  execute(<<-SQL)
     SELECT
      company,
      num,
      COUNT(*)
    FROM
      routes
    WHERE
      stop_id = 149 OR stop_id = 53
    GROUP BY
      company, num
    HAVING COUNT(*) = 2

  SQL
end

def cl_to_lr
  # Consider the query:
  #
  # SELECT
  #   a.company,
  #   a.num,
  #   a.stop_id,
  #   b.stop_id
  # FROM
  #   routes a
  # JOIN
  #   routes b ON (a.company = b.company AND a.num = b.num)
  # WHERE
  #   a.stop_id = 53
  #
  # Observe that b.stop_id gives all the places you can get to from
  # Craiglockhart, without changing routes. Change the query so that it
  # shows the services from Craiglockhart to London Road.
  execute(<<-SQL)
    SELECT
      ra.company,
      ra.num,
      ra.stop_id,
      rb.stop_id
    FROM routes AS ra
    INNER JOIN routes rb
    ON (ra.company = rb.company AND ra.num = rb.num)
    WHERE ra.stop_id = 53 AND rb.stop_id = 149

  SQL
end

def cl_to_lr_by_name
  # Consider the query:
  #
  # SELECT
  #   a.company,
  #   a.num,
  #   stopa.name,
  #   stopb.name
  # FROM
  #   routes a
  # JOIN
  #   routes b ON (a.company = b.company AND a.num = b.num)
  # JOIN
  #   stops stopa ON (a.stop_id = stopa.id)
  # JOIN
  #   stops stopb ON (b.stop_id = stopb.id)
  # WHERE
  #   stopa.name = 'Craiglockhart'
  #
  # The query shown is similar to the previous one, however by joining two
  # copies of the stops table we can refer to stops by name rather than by
  # number. Change the query so that the services between 'Craiglockhart' and
  # 'London Road' are shown.
  execute(<<-SQL)
    SELECT
      ra.company,
      ra.num,
      sa.name,
      sb.name
    FROM routes AS ra
    INNER JOIN stops AS sa
    ON ra.stop_id = sa.id
    INNER JOIN routes rb
    ON (ra.company = rb.company AND ra.num = rb.num)
    INNER JOIN stops AS sb
    ON rb.stop_id = sb.id
    WHERE sa.name = 'Craiglockhart' AND sb.name = 'London Road'
  SQL
end

def haymarket_and_leith
  # Give the company and num of the services that connect stops
  # 115 and 137 ('Haymarket' and 'Leith')
  execute(<<-SQL)
    SELECT DISTINCT
      ra.company,
      ra.num
    FROM
      routes AS ra
    INNER JOIN routes AS rb
    ON (ra.company = rb.company) AND (ra.num = rb.num)
    WHERE ra.stop_id = 115 AND rb.stop_id = 137

  SQL
end

def craiglockhart_and_tollcross
  # Give the company and num of the services that connect stops
  # 'Craiglockhart' and 'Tollcross'
  execute(<<-SQL)
    SELECT
      ra.company,
      ra.num
    FROM
      routes AS ra
    INNER JOIN stops AS sa
    ON ra.stop_id = sa.id
    INNER JOIN routes AS rb
    ON (ra.company = rb.company) AND (ra.num = rb.num)
    INNER JOIN stops AS sb
    ON rb.stop_id = sb.id
    WHERE sa.name = 'Craiglockhart' AND sb.name = 'Tollcross'
  SQL
end

def start_at_craiglockhart
  # Give a distinct list of the stops that can be reached from 'Craiglockhart'
  # by taking one bus, including 'Craiglockhart' itself. Include the stop name,
  # as well as the company and bus no. of the relevant service.
  execute(<<-SQL)
      SELECT DISTINCT
        sa.name,
        ra.company,
        ra.num
      FROM
        routes AS ra
      INNER JOIN stops AS sa
      ON ra.stop_id = sa.id
      INNER JOIN routes AS rb
      ON (ra.company = rb.company) AND (ra.num = rb.num)
      INNER JOIN stops AS sb
      ON rb.stop_id = sb.id
      WHERE sb.name = 'Craiglockhart'
  SQL
end

def craiglockhart_to_sighthill
  # Find the routes involving two buses that can go from Craiglockhart to
  # Sighthill. Show the bus no. and company for the first bus, the name of the
  # stop for the transfer, and the bus no. and company for the second bus.
  execute(<<-SQL)
    SELECT DISTINCT
      ra.num,
      ra.company,
      ts.name,
      rb.num,
      rb.company
    FROM
      routes AS ra
    INNER JOIN stops AS sa
    ON ra.stop_id = sa.id
    INNER JOIN routes AS tr
    ON (tr.company = ra.company) AND (tr.num = ra.num)
    INNER JOIN stops AS ts
    ON tr.stop_id = ts.id
    INNER JOIN routes AS tr2
    ON tr.stop_id = tr2.stop_id
    INNER JOIN routes AS rb
    ON (tr2.company = rb.company) AND (tr2.num = rb.num)
    INNER JOIN stops AS sb
    ON rb.stop_id = sb.id
    WHERE sa.name = 'Craiglockhart' AND sb.name = 'Sighthill'

  SQL
end
