package com.blackwings.crm.settings.service;

import com.blackwings.crm.settings.domain.User;

import java.util.List;
import java.util.Map;

public interface UserService {
    User queryUserByLoginActAndPwd(Map<String, String> map);

    List<User> queryOwner();
}
