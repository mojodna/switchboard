#!/usr/bin/env ruby
require 'fire_hydrant'
require 'rexml/document'
require 'open-uri'

hydrant = FireHydrant.new(YAML.load(File.read("fire_hydrant.yml"))) do
  old_votes = load_results

  while(!shutdown?) do
    # load the results feed
    votes = load_results
    diff = nil

    # loop through and compare it to the old results
    votes.each do |state, cand|
      cand.each do |c, val|
        unless old_votes[state][c] == val
          diff ||= "Electoral results changed"
          diff << "\n#{state} - #{c}: #{old_votes[state][c].inspect} => #{val.inspect}"
        end
      end
    end

    if diff
      puts diff
      broadcast(diff)
    end

    # set this as old_votes
    old_votes = votes

    # wait 5 minutes
    puts "-----"
    sleep 300
  end
end

hydrant.jack!(AutoAcceptJack, NotifyJack)

def hydrant.load_results(url = "http://d.yimg.com/b/data/us/news/xml/elections/2008a/pres.xml")
  doc = REXML::Document.new(open(url))
  nodes = doc.elements.collect("//state") { |node| [node.attributes["name"].downcase, node.elements.collect("cand") { |cand| [cand.attributes["name"].downcase, cand.attributes["PopPct"].to_f, cand.attributes["PopVote"].to_i] }] }

  votes = {}
  nodes.each do |state, results|
    votes[state] = {}
    results.each do |cand, pct, vote|
      votes[state][cand] = [pct, vote]
    end
  end

  votes
end

def hydrant.broadcast(msg)
  roster.items.each do |jid, item|
    client.send(Jabber::Message.new(jid, msg))
  end
end

hydrant.run!
