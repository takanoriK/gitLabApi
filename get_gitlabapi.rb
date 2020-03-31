class GetGitLabApiLabels
  require 'net/http'
  require 'uri'
  require 'json'
  PRIVATE_TOKEN = 'token_id'
  $value = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }

  def getRequestLabels
    url_first = 'https://mygitlab.com/api/v4/projects/'

    #サービスID
    url_id = {'contents_name' => 'id'}

    #未レビューというラベルが付いているMRのみ取得
    url_after = '/merge_requests?state=opened&labels=%E6%9C%AA%E3%83%AC%E3%83%93%E3%83%A5%E3%83%BC&private_token=' + GetGitLabApiLabels::PRIVATE_TOKEN

    #gitLabAPIからデータを取得
    get_datas = getGitLabApi(url_first, url_id, url_after)
    get_datas.each { |contents, requests|
        requests.each do |data|
            setData(contents, data)
        end
    }

    #正常終了
    puts $value

  end
end

# gitLabApi取得
# @param array url_id
# @param string url_after
#
# @return array encode_results
private

def getGitLabApi(url_first, url_id, url_after)
  decode_results = {}
  url_id.each { |contents, project_id|
      culr_url =  URI.parse(url_first + project_id + url_after)
      result = Net::HTTP.get(culr_url)
      if result != '[]' then
        decode_results[contents] = JSON.parse(result)
      end
  }

  return decode_results;
end

# タイトルとレビュー担当をセット
# @param string $contents
# @param array $data
#

def setData(contents, data)
  if  defined?(data['data']) && defined?(data['labels'])
    $value['response'][contents]['title'] = data['title']
    $value['response'][contents]['url'] = data['web_url']
    setTimeLimit(contents, data['title'])
    $value['response'][$contents]['labels']['name1'] = data['labels'][0]
    
    #アサインが2人の場合
    if  defined?(data['title'][1]) && data['title'][1] != '未レビュー'
      $value['response'][contents]['labels']['name2'] = data['labels'][1]
    end

  end
end

def setTimeLimit(contents, title)
    $value['response'][contents]['limit'] = title[4,5]
end

apiclass = GetGitLabApiLabels.new
apiclass.getRequestLabels
