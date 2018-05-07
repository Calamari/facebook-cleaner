require 'selenium-webdriver'
require 'interact'

# This is are the actions, as the activity log page, does name them. If you want to not unlike stuff,
# then you can just remove the 'Unlike' item from here. If you want to unfriend all people you
# befriended that year, you could also add 'Unfriend' here.
POSSIBLE_ACTIONS = ['Delete', 'Unlike', 'Hide from Timeline'].freeze

BROKEN_STRING = 'The page you requested was not found.'
MORE_STRING = 'Load more from'

class Eraser
  include Interactive

  def run
    @retry = 0
    @running = true
    @broken_actions = []
    @closed_months = []
    ask_input
    login
    set_language
    delete_from_activity_log(@year)
  ensure
    driver.quit
  end

  def ask_input
    @email = ask 'E-Mail'
    @password = ask 'Password', echo: '*', forget: true
    @profile_name = ask 'Profile name'
    @year = ask 'Delete what year?'
    exit unless ask 'We need to change your Facebook language to English (UK), is that ok?', default: true
  end

  def login
    driver.navigate.to 'https://mbasic.facebook.com'
    email_element = driver.find_element(id: 'm_login_email')
    email_element.send_keys(@email)
    password_element = driver.find_element(xpath: '//input[@type="password"]')
    password_element.send_keys(@password)
    password_element.submit()

    # Ensure not to land on the one tap login page
    driver.navigate.to 'https://mbasic.facebook.com'
  end

  def set_language
    driver.navigate.to 'https://mbasic.facebook.com/language.php'
    driver.find_element(:link_text, 'English (UK)').click
    driver.navigate.to 'https://mbasic.facebook.com'
  end

  def delete_from_activity_log(year)
    goto_profile
    driver.find_elements(:css, 'a').find {|link| link.text.downcase == 'activity log'}.tap(&:location_once_scrolled_into_view).click
    driver.find_element(:css, "#year_#{year} a").click

    while @running
      begin
        days = driver.find_elements(:xpath, '//div[contains(@id, "tlUnit_")]')
        actions = days
          .map {|d| d.find_elements(:css, 'a')}
          .flatten
          .select {|l| POSSIBLE_ACTIONS.include?(l.text) && !@broken_actions.include?(l['href'].gsub(/ext=(.*)/, '')) }
          .sort_by { |a| POSSIBLE_ACTIONS.index(a) }
        if actions.length > 0
          action = actions.first
          last_href = action['href'].gsub(/ext=(.*)/, '')
          action.click()
          if is_broken?
            @broken_actions.push(last_href)
            driver.navigate.back
          else
          end
        else
          begin
            click_more_link
          rescue Selenium::WebDriver::Error::NoSuchElementError => e
            goto_next_month
          end
        end
      rescue StandardError => e
        sleep 1
        @retry += 1
        throw e if @retry > 3
        p "Something happened"
        p e
        p "retrying #{@retry}…"
      end
    end
  rescue StandardError => e
    p e
  end

  def goto_profile
    driver.find_element(:css, '[role=navigation] a:nth-child(2)').click
  end

  def goto_next_month
    months = driver.find_elements(:xpath, "//div[contains(@id, 'month_#{@year}_')]/a")
    selected_month = months.find {|l| !@closed_months.include?(l.text) }
    if selected_month
      @closed_months.push(selected_month.text)
      selected_month.click
    else
      p "We are done. GREAT!"
      @running = false
    end
  end

  def is_broken?
    driver.find_elements(:xpath, "//*[contains(text(), '#{BROKEN_STRING}')]").length > 0
  end

  def click_more_link
    driver.find_element(:xpath, "//*[contains(text(), '#{MORE_STRING}')]").click
  end

  private

  def driver
    # If you need another browser, please change it here. E.g. :firefox
    @driver ||= Selenium::WebDriver.for :chrome
  end
end

Eraser.new.run
