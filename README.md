# Mumble

An example of how to structure the core domain models of Culture Amp within a plain Ruby project.

This was homework for Week 3 of the program:

> Homework for this week: model the remainder of the system in the Mumble application. Make sure to write tests _before_ you write any code!
>
> Stretch goal #1: Come up with a way to find all answers to a particular question on a survey. You might have to filter through all the responses of the survey to find their respective answers. Or is there a better way of modelling this data?
>
> Stretch goal #2 : Add a `Segment` class. A User has many segments, and segments have names. Then work out a way to filter a particular survey's responses based on a set of segments. So given a list of responses which might look like:
>
> * Response 1: User with segments: Melbourne, JEP, Male
> * Response 2: User with segments: Melbourne, A&U, Female
> * Response 3: User with segments: Melbourne, Effectiveness, Female
> * Response 4: User with segments: SF, CSE, Female
>
> A query for all the responses which match the segments [Melbourne] should return Response 1, 2 & 3. While a query for segments [Melbourne, Female] should match Responses 2 & 3.

Here's my own attempt at the problem.

## Notes

### Responses class

The logic for working with a array of responses lives in the `Responses` class.

The homework stretch goals end up both working with an array of responses in different ways: one to get the answers, and the other to filter the responses by some given segments.

#### Stretch Goal #1: answers for a particular question

This goal involves finding all the answers to a survey for a particular question. But in order to get them, you have to reach from survey into responses, and then for each response get all their answers. Only then can you do the right filtering -- picking out only the answers that belong to the right question.

So when approaching this first stretch goal, my initial attempt was to put this code into the `Survey` class; just to get the tests to pass.

```ruby
def answers_for_question(question)
  responses.flat_map(&:answers).select do |answer|
    answer.question == question
  end
end
```

Having this logic live in the `Survey` class doesn't feel _right_ because the Survey class should only know how to do things to / with Survey objects. By having that class reach into responses like this for Stretch Goal #1, I'm making the `Survey` class know these things:

* How to get the answers for a `Response` instance
* How to get the question for an `Answer` instance

This is what's referred to as a [_Law of Demeter_](https://en.wikipedia.org/wiki/Law_of_Demeter) violation. The linked Wikipedia article has a great analogy:

> when one wants a dog to walk, one does not command the dog's legs to walk directly; instead one commands the dog which then commands its own legs.

Having this code in `Survey` isn't going to cut it, because code inside of `Survey` should only have to work with things that are _directly_ related to surveys.

Not only this, but by having this class's code work with responses, it breaks the _Single Responsibility Principle_ rule: classes (and methods, for that matter) should only have one single responsibility.

A class (or method) with more than one responsibility becomes harder to reason about or change the more responsibilities it has. A good test-case for this is to try and explain a class (or a method) in a sentence. If that sentence uses the word "and" then the class (or method) could probably be split up into smaller classes (or methods).

Individual responses aren't directly related to surveys because the association there is `<survey instance> -> <responses array> -> <response>`, so that's a no-go zone.

To tidy this code up, I needed _something else_ that I could get a `Survey` instance to talk to. That _something else_ will get me all the answers for the question that I ask for. For this I came up with the `Responses` class. That class will be the entry point from surveys.

The plan was: Surveys makes method calls to a `Responses` instance and that then does the hard work of figuring out how to fetch the right answers.

So then I went about creating the `Responses` class. It started out like this:

```ruby
module Mumble
  class Responses
    attr_reader :responses

    def initialize(responses = [])
      @responses = responses
    end
  end
end
```

This is intended to be a small wrapper around the array of responses, but it doesn't do anything useful at the moment. We can start using it in `Survey`:

```ruby
module Mumble
  class Survey
    attr_reader :account, :name, :responses, :questions

    def initialize(account:, name:)
      @account = account
      @name = name
      @responses = Responses.new
      @questions = []
    end

    ...
```

I needed a way of adding responses to this array, so I added a method to `Survey` called `add_response`:

```ruby
def add_response(response)
  @responses.add(response)
end
```

And then added the `Responses#add` method:

```ruby
def add(response)
  @responses << response
end
```

So now that we have this `@responses` variable using an instance of the `Responses` class, we can change our `Survey#answers_for_question` method to ask this object for the answers for the question:

```ruby
def answers_for(question)
  responses.answers_for(question)
end
```

This is better now because there is no longer any logic in the `Survey` class for fetching the answers matching the question. That's now going to be `Responses` job. In `survey_spec.rb`, we can stub out what `answers_for` returns here:


```ruby
context "answers_for" do
  let(:question) { instance_double(Mumble::Question) }

  context "when a survey has responses with answers" do
    let(:responses) { instance_double(Mumble::Responses) }

    before do
      allow(survey).to receive(:responses) { responses }
      allow(responses).to receive(:answers_for) { [1, 2] } # THIS LINE
    end

    it "can find answers for specific questions" do
      expect(survey.answers_for(question)).to eq([1, 2])
    end
  end
end
```

In the above test, we're creating an `instance_double` of `Mumble::Responses` and then saying that when that instance double receives `answers_for`, then it will return an array of `[1, 2]`. We're checking that when `answers_for` is called on `Survey` that it also returns the same array. This test makes sure that the `Survey` class calls out to the `responses` object to do the hard work of fetching the right answers.

Speaking of, we should now add that logic to the `Responses` class so that it does the right filtering:

```ruby
module Mumble
  class Responses
    attr_reader :responses

    def initialize(responses = [])
      @responses = responses
    end

    def answers_for_question(question)
      responses.flat_map(&:answers).select do |answer|
        answer.question == question
      end
    end
  end
end
```

You might notice here that the code in `Responses#answers_for_question` is the same as the code in `Survey#answers_for_question`. But this an important move to make, because it moves the logic out of the `Survey` class where it _doesn't_ belong into a `Responses` class, where it _does_ belong. Again: it _doesn't_ belong in the `Survey` class because that class should only concern itself with survey things.

This code in `Responses#answers_for_question` is working with an array of responses, and so the `Responses` class, which has instances that represent arrays of responses, seems like a sensible place to put it.

But can we go even further with this code-shuffling? You betcha.

This `Responses` class has implicit knowledge about how a `Response` instance is structured -- becuase it knows that `Response` instances have `answers` methods -- and it also knows how an `Answer` instance is structured -- it knows that `Answer` instances have `question` methods. So it _feels_ to me like the bulk of this method's code still doesn't belong here. What would be better is if this `Responses` class asked each of the `Response` instances to fetch the answers for a particular question.

So let's change that `answers_for_question` method a little more:

```ruby
def answers_for_question(question)
  responses.map { |response| response.answer_for_question(question) }
end
```

All `Responses` instances now pass the buck to each `Response` instance to ask them to return their answer for a particular question. If you're curious what the tests look like, well, here they are:

```ruby
RSpec.describe Mumble::Responses do
  context "answers_for" do
    let(:question) { instance_double(Mumble::Question) }
    let(:answer1) { instance_double(Mumble::Answer, question: question) }
    let(:answer2) { instance_double(Mumble::Answer, question: question) }
    let(:response1) { instance_double(Mumble::Response, answer_for_question: answer1) }
    let(:response2) { instance_double(Mumble::Response, answer_for_question: answer2) }

    subject(:responses) do
      Mumble::Responses.new([
        response1,
        response2
      ])
    end

    it "gets all the answers for a given question" do
      answers = responses.answers_for_question(question)
      expect(answers).to match_array([answer1, answer2])
    end
  end
end
```

Notice that when `response1` and `response2` are setup, we're stubbing that `answer_for_question` method to return hard-coded answers. So when `repsonses.answers_for_question` is returned in the test, we're asserting that those same answers are returned by that method. The `match_array` matcher here is used (rather than `eq`) just so that we're not reliant on the order of the array; the `eq` method is strict that the expected-vs-actual arrays have to be in the same order. `match_array` is way more chill about that sort of thing and only checks that the array's elements are present, but not necessarily in the same order. Order is not important for the `answers_for_question` method.

So the next step would be to define this `Response#answer_for_question` method. This method is called the singular version `answer_for_question` rather than `answers_for_question` because a single response can only have zero-or-one answer for a question. In our model, it can't have more than one.

So I defined this method like this:

```ruby
def answer_for_question(question)
  answers.detect { |answer| answer.question == question }
end
```

This method will find the _first_ answer that matches the given question and return that. If it can't find one, it returns `nil` instead.

There's one step further that we _could_ go here: `Response` knows that `Answer` instances have a `question` attribute, and so we should probably move the `answer.question` check into the `Answer` class too. I tried doing this but it _felt_ like to me that it was one level of abstraction too far and it didn't really tidy things up in any meaningful sense -- like the last few changes have.

If you're curious about what that would look like anyway, it would be this code in the `Response` class:

```ruby
def answer_for_question(question)
  answers.detect { |answer| answer.for_question?(question) }
end
```

And then this code in the `Answer` class:

```ruby
def for_question?(other_question)
  question == other_question
end
```

So while it's good-and-proper to follow the letter of the law strictly, sometimes it's also good to break the rules if you feel like they're _too_ strict. I used my own judgement here... but now that I'm writing it up for you, I feel like I _might've_ judged incorrectly. Oh well, these things can happen!

So, a quick re-cap!

The goal was:

> Come up with a way to find all answers to a particular question on a survey. You might have to filter through all the responses of the survey to find their respective answers. Or is there a better way of modelling this data?

The keywords here being _on a survey_, which makes me think that this method should go on the `Survey` class. We put an `answers_for_question` method there, but the code was a little messy:

```ruby
def answers_for_question(question)
  responses.flat_map(&:answers).select do |answer|
    answer.question == question
  end
end
```

I mentioned that this violates the [_Law of Demeter_](https://en.wikipedia.org/wiki/Law_of_Demeter), and is also breaking the Single Responsibility Prinicple: the `Survey` class now works directly with both surveys and arrays of responses.

So I moved that code out to a `Responses` class, ending up with this:

```ruby
module Mumble
  class Responses
    attr_reader :responses

    def initialize(responses = [])
      @responses = responses
    end

    def add(response)
      @responses << response
    end

    def answers_for_question(question)
      @responses.map { |response| response.answer_for_question(question) }
    end
  end
end
```

So the `Survey` class delegates responsibility of finding the answers for a question to this `Responses` class, which then delegates further to each `Response` instance. The `Response` instance's code to find the answer was this:

```ruby
def answer_for_question(question)
  answers.detect { |answer| answer.question == question }
end
```

The major benefit of this is that `Survey` has no knowledge at all of _how_ the answers are found, and so it makes reasoning about or changing that class easier: you don't have to think of it as having that responsibility because it delegates to `Responses`. Then `Responses` _itself_ doesn't know how the answers are found because `Response` has that responsibility.

### Stretch Goal #2: Adding a Segment class, and filtering responses

This goal involves finding responses that match a particular set of segments. You can think of segments as a _category_ or a _group_ or a _demographic_ that people belong to. These are commonly used to segment our responses on our surveys at Culture Amp so we can see how a particular group of people responded to a survey.

By design, the Mumble diagram did _not_ include a `Segment` class, and so we need to add in one of these to our Mumble codebase. I've added mine to `lib/mumble/segment.rb` and it's fairly bare-bones:

```ruby
module Mumble
  class Segment
    attr_reader :name

    def initialize(name:)
      @name = name
    end
  end
end
```

An instance of the `Segment` class will represent a segment's name and that's all. Next, I need to associate segments and users together. Users have many different segments that they're a part of and so in the `User` class I've changed the code to this:

```ruby
module Mumble
  class User
    attr_reader :segments

    def initialize(segments:)
      @segments = segments
    end
  end
end
```

I could also have an `email` attribute on the `User` class to identify the users more specifically, but I don't really care for or need that right now. A user just represents an anonymous user who is within a group of segments.

The goal is to find the responses for a particular segment combination _on a survey_, so this makes me think that the method should go in the `Survey` class. Again: my goal is to get a _working_ method, not the _cleanest ever_ method to start with. Make it work, then make it pretty! So here's what I put down first:

```ruby
def responses_for_segments(segments)
  responses.select do |response|
    segments.all? { |segment| response.user.segments.include?(segment) }
  end
end
```

This method again violates the Law of Demeter (just like we saw in Goal #1) because `Survey` instances know too much about the `Response` instances it works with -- it knows that it has a `user` method, and it knows that whatever that returns has a `segments` method. It also breaks the Single Responsibility Principle: `Survey` know has knowledge about how to work with responses.

So just like before, we're going to move the logic for working with a collection of responses out of `Survey` and into the `Responses` class. First, we'll need to re-define the `responses_for_segments` method to call out to that `responses` instance:

```ruby
def responses_for_segments(segments)
  responses.for_segments(segments)
end
```

Then in the `Responses` class, we can put the bulk of that logic:

```ruby
def for_segments(*segments)
  responses.select do |response|
    segments.all? { |segment| response.user.segments.include?(segment) }
  end
end
```

Ok, this is better! `Survey` doesn't know anything about how responses are filtered to the ones matching the segments, but `Responses` still knows a little too much about `Response` methods for my liking. So let's go a little further in `Responses#for_segment`:

```ruby
def for_segments(*segments)
  responses.select { |response| response.within_segments?(segments) }
end
```

This `Response#within_segments?` method would now contain that logic that was within the `select` method:

```ruby
def within_segments?(segments)
  segments.all? { |segment| user.segments.include?(segment) }
end
```

This `within_segments?` method still feels _heavy_ to me. The `Response` instances still need to know about how `User` instances are structured -- it knows about the `segments` method. So I think that this logic should live in the `User` class:

```ruby
def within_segments?(segments)
  segments.all? { |segment| user.in_segment?(segment) }
end
```

That's better! This `User#in_segment?` method would then contain that little bit of logic that used to live in that block:

```ruby
def in_segment?(segment)
  segments.include?(segment)
end
```

So to recap here:

1. `Survey#responses_for_segments` delegates to `Responses#for_segments`
2. `Responses#for_segments` filters the responses by using the `Response#within_segments?` method.
3. `Response#within_segments?` determines if the response matches the specified segments by using `User#in_segment?` on each segment. If all of those checks return `true` then the response is considered to be within the segment.

If all of that is a little confusing, check out `bin/stretch2.rb` which shows how I build all the relevant instances and then use these methods.

### Rubocop
